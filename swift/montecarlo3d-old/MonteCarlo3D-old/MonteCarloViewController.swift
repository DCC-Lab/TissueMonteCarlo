//
//  GameViewController.swift
//  MonteCarlo3D
//
//  Created by Daniel Côté on 2015-03-23.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import SceneKit
import QuartzCore


func synced(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

let transparentContext = UnsafeMutablePointer<Void>(bitPattern:100)
let sourceContext = UnsafeMutablePointer<Void>(bitPattern:101)
let photonContext = UnsafeMutablePointer<Void>(bitPattern:102)

class MonteCarloViewController: NSViewController {
    
    @IBOutlet weak var gameView: MonteCarloView!
    @IBOutlet weak var sourcePosition: NSTextField!
    @IBOutlet weak var sourceDirection: NSTextField!
    @IBOutlet weak var numberOfPhotons: NSTextField!
    @IBOutlet weak var startStopButton: NSButton!
    @IBOutlet weak var progressField: NSTextField!

    var isCalculating:Bool {
        return queue.operationCount != 0
    }
    
    var modelPath:String?
    var outputPath:String?
    var showPhotonTraces:Bool?
    var queue:NSOperationQueue
    
    var scene:SCNScene
    
    required init?(coder: NSCoder) {
        self.scene = SCNScene(named: "SpinalCord3D.dae", inDirectory: nil, options: nil)!
        self.scene = SCNScene()
        queue = NSOperationQueue()
        super.init(coder:coder)
    }
    override func awakeFromNib(){
        NSUserDefaultsController.sharedUserDefaultsController().addObserver(self, forKeyPath: "values.outputPath", options: NSKeyValueObservingOptions.New, context: transparentContext)

        NSUserDefaultsController.sharedUserDefaultsController().addObserver(self, forKeyPath: "values.transparentObjects", options: NSKeyValueObservingOptions.New, context: transparentContext)

        
        NSUserDefaultsController.sharedUserDefaultsController().addObserver(self, forKeyPath: "values.showSource", options: [NSKeyValueObservingOptions.New], context: sourceContext)
        NSUserDefaultsController.sharedUserDefaultsController().addObserver(self, forKeyPath: "values.showPhotonTraces", options: [NSKeyValueObservingOptions.New], context: photonContext)
        NSUserDefaultsController.sharedUserDefaultsController().addObserver(self, forKeyPath: "values.sourceOrigin", options: [NSKeyValueObservingOptions.New], context: sourceContext)

        setupScene()
        constructPhysicalGeometry()
        addPropertiesToGeometry()
        scene.dumpTree()
        updateSceneWithUserSelections()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if context == sourceContext || context == transparentContext {
            updateSceneWithUserSelections()
        } else if context == photonContext {
            let value = NSUserDefaultsController.sharedUserDefaultsController().valueForKeyPath("values.showPhotonTraces")
            if value != nil {
                showPhotonTraces = value!.boolValue
            }

        }
    }

    func updateSceneWithUserSelections() {
        removeMonteCarloLightSource()

        var value = NSUserDefaultsController.sharedUserDefaultsController().valueForKeyPath("values.showSource")
        
        if value != nil {
            let showSource = (value!.boolValue)!
            if showSource {
                addMonteCarloLightSource()
            } else {
                removeMonteCarloLightSource()
            }
        }

        value = NSUserDefaultsController.sharedUserDefaultsController().valueForKeyPath("values.transparentObjects")
        
        if value != nil {
            let transparent = (value!.boolValue)!
            if transparent {
                setObjectsOpacity(0.5)
            } else {
                setObjectsOpacity(1.0)
            }
        }
    }
    
    @IBAction func userClickedStartStop(sender:AnyObject) {
        if queue.operationCount != 0 {
            queue.cancelAllOperations()
            queue.waitUntilAllOperationsAreFinished()
            startStopButton.title = "Calculate"
            self.progressField.doubleValue = 0.0
            
        } else {
            let position = SCNVector3.vectorFromString(sourcePosition.stringValue)
            let direction = SCNVector3.vectorFromString(sourceDirection.stringValue)
            let N = Int(numberOfPhotons.stringValue)

            if position == nil || direction == nil || N == nil {
                return
            }

            var node:SCNNode?
            repeat {
                node = self.scene.rootNode.childNodeWithName("Line", recursively: true)
                node?.removeFromParentNode()
            } while (node != nil)
            
            startStopButton.title = "Stop"
            self.progressField.doubleValue = 0.0

            let time = UInt32(NSDate().timeIntervalSinceReferenceDate)
            srand(time)

            queue.maxConcurrentOperationCount = 1
            queue.qualityOfService = NSQualityOfService.UserInteractive
            let chunk = 10;
            for _ in 0...N!/chunk {
                queue.addOperationWithBlock({ self.calculatePropagation(position!, direction: direction!, numberOfPhotons: chunk)
                self.progressField.doubleValue += Double(chunk)/Double(N!)
                })
            }
            
        }
    }

    @IBAction func userClickedSelectOutputFile(sender:AnyObject) {
        let savePanel = NSSavePanel()
            
        if savePanel.runModal() == NSFileHandlingPanelOKButton {
            NSUserDefaultsController.sharedUserDefaultsController().setValue(savePanel.URL?.path, forKeyPath: "values.outputPath")
        }
        
    }

    @IBAction func userClickedSelectModelFile(sender:AnyObject) {
        let openPanel = NSOpenPanel()

        if openPanel.runModal() == NSFileHandlingPanelOKButton {
            NSUserDefaultsController.sharedUserDefaultsController().setValue(openPanel.URL?.path, forKeyPath: "values.modelPath")
        }

    }
    
    func calculatePropagation(position:SCNVector3, direction:SCNVector3, numberOfPhotons N:Int) {
        outputPath = NSUserDefaultsController.sharedUserDefaultsController().valueForKeyPath("values.outputPath") as? String
        
        if outputPath == nil {
            return
        }
        
        do {
            for _ in 1...N {
                let photon = Photon(position: position, direction: direction, wavelength: 632e-7)
                
                if photon != nil {
                    try photon?.propagateInto(self.scene.rootNode, distance: 0)
                    
                    if showPhotonTraces == true {
                        var vertexList:[SCNVector3]=[]
                        for tuple in photon!.statistics {
                            let (vertex, weight) = tuple
                            vertexList.append(vertex)
                            
                            let text = NSString(format: "%f\t%f\t%f\t%f\n", vertex.x, vertex.y, vertex.z, weight)
                            let data: NSData = text.dataUsingEncoding(NSUTF8StringEncoding)!

    //                        objc_sync_enter(self)
    //                            let outputStream = NSOutputStream(toFileAtPath: outputPath!, append: true)
    //                            outputStream?.open()
    //                            outputStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    //                            outputStream?.close()
    //                        objc_sync_exit(self)
                        }
                        SCNTransaction.begin()
                        self.scene.addLine(vertexList)
                        SCNTransaction.commit()
                    }
                }
            }
        } catch MonteCarloError.UnexpectedNil {
            print ("Programming error: incomplete code")
        } catch {
            print ("Programming error: unknown")
        }
    }

    func setupScene() {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = NSColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // set the scene to the view
        self.gameView!.scene = scene
        
        // allows the user to manipulate the camera
        self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = false
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.blackColor()
        
    }
    
    func addMonteCarloLightSource() {
        let objectGeometry = SCNSphere(radius: 0.1)
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.name = "LightSource"
        let position = SCNVector3.vectorFromString(sourcePosition.stringValue)
        if position != nil {
            objectNode.position = position!
        }
        scene.rootNode.addChildNode(objectNode)
        objectNode.hidden = false
    }

    func removeMonteCarloLightSource() {
        let lightSource = self.scene.rootNode.childNodeWithName("LightSource", recursively: true)
        lightSource?.removeFromParentNode()
    }

    func constructPhysicalGeometry() {
        
//        let objectGeometry = SCNSphere(radius: 5)
        let objectGeometry = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 0)
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.position = SCNVector3(x: 0, y: 0, z: 0)
        objectNode.name = "WhiteMatter"
        objectNode.opacity = 0.5
        objectNode.hidden = false

        SCNTransaction.begin()
        scene.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()

        objectNode.dumpAllPrimitives()
        
        
    }

    func setObjectsOpacity(alpha:CGFloat) {
        let whiteMatter = self.scene.rootNode.childNodeWithName("WhiteMatter", recursively: true)
        
        if whiteMatter != nil {
            whiteMatter?.opacity = alpha
        }

        let greyMatter = self.scene.rootNode.childNodeWithName("GrayMatter", recursively: true)
        
        if greyMatter != nil {
            greyMatter?.opacity = alpha
        }
    
    }
    
    func addPropertiesToGeometry() {
        let whiteMatter = self.scene.rootNode.childNodeWithName("WhiteMatter", recursively: true)
        
        if whiteMatter != nil {
            whiteMatter?.addChildNode(BulkHenyeyGreenstein(mu_s: 4, mu_a: 0.1, index: 1.4 , g:0))
        }

        let greyMatter = self.scene.rootNode.childNodeWithName("GrayMatter", recursively: true)
        
        if greyMatter != nil {
            greyMatter?.addChildNode(BulkHenyeyGreenstein(mu_s: 2, mu_a: 0.1, index: 1.4 , g:0))
        }

        let air = BulkMaterial(mu_s: 0, mu_a: 0.1, index: 1)
        self.scene.rootNode.addChildNode(air)

    }
}



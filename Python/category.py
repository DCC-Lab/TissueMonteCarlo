class category(object):
    def __init__(self, mainModule, override = True):
        self.mainModule = mainModule
        self.override = override

    def __call__(self, function):
        if self.override or function.__name__ not in dir(self.mainModule):
            setattr(self.mainModule, function.__name__, function)

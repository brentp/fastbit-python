# from: https://github.com/scoder/lupa/raw/master/lupa/tests/__init__.py
def suite():
    import unittest
    import os
    test_dir = os.path.abspath(os.path.dirname(__file__))

    tests = []
    for filename in os.listdir(test_dir):
        if filename.endswith('.py') and not filename.startswith('_'):
            tests.append(unittest.findTestCases('tests.'+ filename[:-3]))
    return unittest.TestSuite(tests)


if __name__ == '__main__':
    import unittest
    #unittest.main()
    unittest.TestRunner(verbosity=2).run(suite())

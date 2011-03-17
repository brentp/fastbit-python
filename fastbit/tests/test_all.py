
import tempfile
import unittest
import os.path as op
import shutil
import sys
sys.path = [op.join(op.dirname(__file__), "..", "..")] + sys.path
import fastbit

class TestFastBit(unittest.TestCase):
    datadir = tempfile.mkdtemp(suffix='fastbit.testcase')

    def tearDown(self):
        if op.exists(self.datadir):
            shutil.rmtree(self.datadir, True)

class TestCreation(TestFastBit):
    def test_create(self):
        f = fastbit.FastBit(self.datadir)
        assert f

class TestWithValues(TestFastBit):
    def setUp(self):
        pass


if __name__ == "__main__":
    suite = unittest.TestSuite()
    import doctest
    #suite.addTest(doctest.DocTestSuite(fastbit._fastbit))
    suite.addTest(unittest.defaultTestLoader.loadTestsFromName('__main__'))
    suite.addTest(doctest.DocFileSuite('../../README.rst'))
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suite)

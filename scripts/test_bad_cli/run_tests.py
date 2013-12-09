#!/usr/bin/env python

import os

tests = [ 'test_unknown_token',
          'test_invalid_param1',
          'test_invalid_param2',
          'test_invalid_param3',
          'test_invalid_keyword' ]

num_passed = 0
num_failed = 0
for t in tests:
    if os.system('./../../scripts/mk_parser.py %s.cli | diff - %s.out' % (t, t)) == 0:
        print 'PASS: %s' % t
        num_passed += 1
    else:
        print 'FAIL: %s' %t
        num_failed += 1
print 'Total=%d  Passed=%d  Failed=%d' % (num_passed + num_failed,
                                          num_passed, num_failed)

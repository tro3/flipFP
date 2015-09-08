q = require 'q'
assert = require('chai').assert
p = console.log

fp = require '../src/flipFP'


#  class mockPromise
#    constructor: (cb) ->
#      @thenCB = null
#      setTimeout 1, -> cb(@resolve)
#    resolve: (val) ->
#      @thenCB(val)
#    then: (cb) ->
#      @thenCB = cb
#      
promise = (val) ->
  q.Promise (resolve, reject) ->
    setTimeout (-> resolve(val)),1
  
describe 'tmp', ->  
  describe 'all', ->
    it 'handles basic cases', ->
      testFn = fp.all (x) -> x > 5
      assert.isTrue testFn [6,7,8,9]
      assert.isFalse testFn [6,7,1,9]
  
    it 'handles piped cases', ->
      genFn = (x) -> [6,7,x,9]
      testFn = fp.all ((x) -> x > 5), genFn
      assert.isTrue testFn 8
      assert.isFalse testFn 1
  
    it 'handles noncurried cases', ->
      testFn = (x) -> x > 5
      assert.isTrue fp.all testFn, [6,7,8,9]
      assert.isFalse fp.all testFn, [6,7,1,9]
  
  
  describe 'allPass', ->
    it 'handles basic cases', ->
      testFn = fp.allPass [
        (x) -> x > 5
        (x) -> x < 10
      ]
      assert.isTrue testFn 6
      assert.isFalse testFn 1
      assert.isFalse testFn 12
  
    it 'handles piped cases', ->
      genFn = (x) -> x*2
      testFn = fp.allPass [
        (x) -> x > 5
        (x) -> x < 10
      ], genFn
      assert.isTrue testFn 3
      assert.isFalse testFn 1
      assert.isFalse testFn 6
  
    it 'handles noncurried cases', ->
      testFn = [
        (x) -> x > 5
        (x) -> x < 10
      ]
      assert.isTrue fp.allPass testFn, 6
      assert.isFalse fp.allPass testFn, 1
      assert.isFalse fp.allPass testFn, 12
  
  
  describe 'always', ->
    it 'handles basic case', ->
      testFn = fp.always 1
      assert.equal (testFn 6), 1
  
  
  describe 'any', ->
    it 'handles basic cases', ->
      testFn = fp.any (x) -> x > 5
      assert.isTrue testFn [1,3,7,3]
      assert.isFalse testFn [2,3,1,4]
  
    it 'handles piped cases', ->
      genFn = (x) -> [x,x+1,x+2]
      testFn = fp.any ((x) -> x > 5), genFn
      assert.isTrue testFn 4
      assert.isFalse testFn 2
  
    it 'handles noncurried cases', ->
      testFn = (x) -> x > 5
      assert.isTrue fp.any testFn, [1,3,7,3]
      assert.isFalse fp.any testFn, [2,3,1,4]
  
  
  describe 'anyPass', ->
    it 'handles basic cases', ->
      testFn = fp.anyPass [
        (x) -> x > 10
        (x) -> x < 5
      ]
      assert.isTrue testFn 3
      assert.isTrue testFn 12
      assert.isFalse testFn 8    
  
    it 'handles noncurried cases', ->
      testFn = [
        (x) -> x > 10
        (x) -> x < 5
      ]
      assert.isTrue fp.anyPass testFn, 3
      assert.isTrue fp.anyPass testFn, 12
      assert.isFalse fp.anyPass testFn, 8    
  
  
  describe 'callAll', ->
    it 'handles basic case', ->
      testFn = fp.callAll [
        (x) -> x + 1
        (x) -> x - 2
      ]
      assert.deepEqual (testFn 8), [9, 6]    
  
    it 'handles noncurried case', ->
      testFns = [
        (x) -> x + 1
        (x) -> x - 2
      ]
      assert.deepEqual fp.callAll(testFns, 8), [9, 6]    
  
  
  describe 'chain', ->
    it 'handles basic case', ->
      testFn = fp.chain (x) -> [x,x]
      assert.deepEqual testFn([1,2]), [1,1,2,2]
  
  
  describe 'clone', ->
    it 'handles basic case', ->
      val = {a:1, b:{c:2}, d:[{e:3}], f:[4]}
      assert.deepEqual fp.clone(val), val
      assert.isFalse fp.clone(val) == val
  
  
  describe 'compose', ->
    it 'handles basic case', ->
      fn1 = (x) -> x+2
      fn2 = (x) -> x/2
      fn = fp.map (fp.compose fn2, fn1)
      assert.deepEqual (fn [2,4,6]), [2,3,4]
  
    it 'handles mutiple args of first function', ->
      fn1 = (x, y) -> x+2 + y
      fn2 = (x) -> x/2
      fn = fp.compose fn2, fn1
      assert.deepEqual fn(3, 1), 3
  
  
  describe 'composeP', ->
    it 'handles direct case', ->
      fn1 = (x, y) ->  promise(x+2+y)
      fn2 = (x) ->     promise(x/2)
      fn3 = (x) ->     promise(x+1)
      (fp.composeP fn3, fn2, fn1)(3,1).then (val) ->      
        assert.deepEqual val, 4

    it 'handles compiled case', ->
      fn1 = (x, y) ->  promise(x+2+y)
      fn2 = (x) ->     promise(x/2)
      fn3 = (x) ->     promise(x+1)
      testFn = fp.composeP fn3, fn2, fn1
      testFn(3,1).then (val) ->      
        assert.deepEqual val, 4
  
  
  describe 'concat', ->
    it 'handles basic case', ->
      assert.deepEqual fp.concat([1], [2,3], [4]), [1,2,3,4]
  
    it 'handles non-Array case', ->
      assert.deepEqual fp.concat(1, [2,3], 4), [1,2,3,4]
  
  
  describe 'filter', ->
    it 'handles basic case', ->
      testFn = fp.filter (x) -> x < 5
      assert.deepEqual (testFn [1,6,4,8,2]), [1,4,2]
  
    it 'handles noncurried case', ->
      testFn = (x) -> x < 5
      assert.deepEqual (fp.filter testFn, [1,6,4,8,2]), [1,4,2]
  
  
  describe 'filterIndex', ->
    it 'handles basic case', ->
      testFn = fp.filterIndex (x, i) -> x < i
      assert.deepEqual (testFn [2.0,2.1,2.2,2.3,2.4]), [2.3,2.4]
  
    it 'handles noncurried case', ->
      testFn = (x, i) -> x < i
      assert.deepEqual (fp.filterIndex testFn, [2.0,2.1,2.2,2.3,2.4]), [2.3,2.4]
  
  
  describe 'flatten', ->
    it 'handles basic case', ->
      assert.deepEqual fp.flatten([[1,2],[3,4]]), [1,2,3,4]
  
    it 'handles nested case', ->
      assert.deepEqual fp.flatten([[1,2],[[3],[4]]]), [1,2,3,4]
  
    it 'handles curried case', ->
      testFn = (x,y) -> [[x,y],[[x+2],[y+2]]]
      assert.deepEqual (fp.flatten testFn)(2,4), [2,4,4,6]
  
  
  describe 'keys', ->
    it 'handles handles basic case', ->
      val = {a:1, b:{c:2}, d:[{e:3}], f:[4]}
      assert.sameMembers fp.keys(val), ['a','b','d','f']
  
  
  describe 'id', ->
    it 'handles handles basic case', ->
      val = {a:1, b:{c:2}, d:[{e:3}], f:[4]}
      assert.equal fp.id(val), val
  
  
  describe 'isNothing', ->
    it 'handles handles basic cases', ->
      assert.isTrue fp.isNothing(null), 'null'
      assert.isTrue fp.isNothing(undefined), 'undefined'
      assert.isTrue fp.isNothing(''), 'empty string'
      assert.isTrue fp.isNothing(' '), 'whitespace string'
      assert.isTrue fp.isNothing([]), 'empty array'
      assert.isTrue fp.isNothing({}), 'empty object'
      assert.isFalse fp.isNothing(0), 'zero'
      assert.isFalse fp.isNothing(false), 'false'
  
    it 'handles handles curried cases', ->
      testFn = fp.isNothing (x,y) -> if x == 1 then [] else [x+y]
      assert.isTrue testFn(1,2)
      assert.isFalse testFn(2,3)
      
  
  
  describe 'map', ->
    it 'handles list of primitives', ->
      fn = fp.map (x) -> x+1
      assert.deepEqual (fn [1,2,3]), [2,3,4]
  
    it 'handles list of objects', ->      
      fn = fp.map (x) -> x._id += 1; x
      assert.deepEqual (fn [{_id:1}, {_id:2}]), [{_id:2}, {_id:3}]
  
    it 'handles uncurried case', ->
      fn = (x) -> x+1
      assert.deepEqual (fp.map fn, [1,2,3]), [2,3,4]
  
  
  describe 'mapIndex', ->
    it 'handles list of primitives', ->
      fn = fp.mapIndex (x, i) -> i
      assert.deepEqual (fn [1,2,3]), [0,1,2]
  
    it 'handles list of objects', ->      
      fn = fp.mapIndex (x, i) -> {a:x._id, b:i}
      assert.deepEqual (fn [{_id:1}, {_id:2}]), [{a:1, b:0}, {a:2, b:1}]
  
    it 'handles uncurried case', ->
      fn = (x, i) -> i+1
      assert.deepEqual (fp.mapIndex fn, [3,2,1]), [1,2,3]
  
  
  describe 'mapObj', ->
    it 'handles basic case', ->
      fn = fp.mapObj (x) -> x+1
      assert.deepEqual (fn {a:1, b:1}), {a:2, b:2}
  
  
  describe 'pipe', ->
    it 'handles basic case', ->
      fn1 = (x) -> x+2
      fn2 = (x) -> x/2
      fn = fp.map (fp.pipe fn1, fn2)
      assert.deepEqual (fn [2,4,6]), [2,3,4]
  
    it 'handles mutiple args of first function', ->
      fn1 = (x, y) -> x+2 + y
      fn2 = (x) -> x/2
      fn = fp.pipe fn1, fn2
      assert.deepEqual fn(3, 1), 3


describe 'pipeP', ->
  it 'handles direct case', (done) ->
    fn1 = (x, y) ->  promise(x+2+y)
    fn2 = (x) ->     promise(x/2)
    fn3 = (x) ->     promise(x+1)
      
    (fp.pipeP fn1, fn2, fn3)(3,1).then (val) ->
      assert.deepEqual val, 4
      done()

  it 'handles compiled case', (done) ->
    fn1 = (x, y) ->  promise(x+2+y)
    fn2 = (x) ->     promise(x/2)
    fn3 = (x) ->     promise(x+1)
      
    testFn = fp.pipeP fn1, fn2, fn3
    testFn(3,1).then (val) ->      
      assert.deepEqual val, 4
      done()


describe 'prop', ->
  it 'handles basic case', ->
    testFn = fp.map fp.prop 'id'
    assert.deepEqual testFn([{id:1},{id:2}]), [1,2]

  it 'handles uncurried case', ->
    assert.equal (fp.prop 'id', {id:2}), 2


describe 'reduce', ->
  it 'handles basic case', ->
    testFn = fp.reduce ((acc, val) -> acc+val), 0
    assert.equal testFn([1,2,3]), 6

  it 'handles variable init case', ->
    testFn = fp.reduce ((acc, val) -> acc+val)
    assert.equal testFn(1, [1,2,3]), 7


describe 'splitAt', ->
  it 'handles basic case', ->
    testFn = fp.splitAt 1
    assert.deepEqual testFn([1,2,3]), [[1],[2,3]]

  it 'handles noncurried case', ->
    assert.deepEqual fp.splitAt(1, [1,2,3]), [[1],[2,3]]


describe 'splitHead', ->
  it 'handles basic case', ->
    assert.deepEqual fp.splitHead([1,2,3]), [1,[2,3]]


describe 'tail', ->
  it 'handles basic case', ->
    assert.deepEqual fp.tail([1,2,3]), [2,3]


describe 'take', ->
  it 'handles basic case', ->
    testFn = fp.take 2
    assert.deepEqual testFn([1,2,3]), [1,2]

  it 'handles piped case', ->
    testFn = fp.take 2, (x) -> [x,x+1,4]
    assert.deepEqual testFn(2), [2,3]

  it 'handles direct case', ->
    assert.deepEqual fp.take(2, [1,2,3]), [1,2]


describe 'traverseObj', ->
  it 'handles the copy case', ->
    testFn = fp.traverseObj(fp.id, fp.id, fp.id)
    val = {a:1, b:{c:2}, d:[{e:3}], f:[4]}
    assert.deepEqual testFn(val), val
    
  it 'handles basic case', ->
    valFn = (x) -> x+1
    preFn = (x) -> x['pre']=1; x
    postFn = (x) -> x['post']=1; x
    testFn = fp.traverseObj valFn, preFn, postFn

    val = {a:1, b:{c:2}, d:[{e:3}], f:[4]}
    exp =
      a:2
      b:
        c:3
        pre:2
        post:1
      d:[{
        e:4
        pre:2
        post:1
      }]
      f:[5]
      pre:2
      post:1

    assert.deepEqual (testFn val), exp


describe 'zipObj', ->
  it 'handles the basic case', ->
    testFn = fp.zipObj(['a','b'])
    assert.deepEqual testFn([1,2]), {a:1, b:2}

  it 'handles the noncurried case', ->
    assert.deepEqual fp.zipObj(['a','b'],[1,2]), {a:1, b:2}


describe 'zipKeys', ->
  it 'handles the basic case', ->
    testFn = fp.zipKeys (x) -> x[0].toUpperCase()
    assert.deepEqual testFn(['add', 'subtract']), {add:'A', subtract:'S'}

  it 'handles the noncurried case', ->
    testFn = (x) -> x[0].toUpperCase()
    assert.deepEqual (fp.zipKeys testFn, ['add', 'subtract']), {add:'A', subtract:'S'}


describe 'natural piping', ->
  it 'handles a basic case', ->
    testFn = fp.take 2, fp.map fp.prop 'a'
    assert.deepEqual testFn([{a:1,b:2}, {a:3,b:2}, {a:2,b:2}, {a:4,b:2}]), [1,3]

  it 'handles double pipe', ->
    testFnA = fp.take 2, fp.filter (x) -> x.a > 1
    testFnB = (x) -> [{a:x,b:1}, {a:x+1,b:2}, {a:x+2,b:3}, {a:x+3,b:4}]
    testFn = testFnA testFnB
    assert.deepEqual testFn(0), [{a:2,b:3}, {a:3,b:4}]
    

  it 'handles direct double pipe', ->
    add1 = fp.maybePipeDirect ((x) -> x + 1)
    add2 = add1 add1
    add4 = add2 add2
    assert.equal add1(1), 2
    assert.equal add2(1), 3
    assert.equal add4(1), 5

  it 'handles mixed double pipe', ->
    add = fp.maybePipe ((i) -> (x) -> x + i)
    add1 = add(1)
    add2a = add(1)(add1)
    add2b = add1 add(1)
    add2c = add 1, add1
    add4a = add2a add2b
    add4b = add2b add2a
    assert.equal add1(1), 2
    assert.equal add2a(1), 3
    assert.equal add2b(1), 3
    assert.equal add2c(1), 3
    assert.equal add4a(1), 5
    assert.equal add4b(1), 5

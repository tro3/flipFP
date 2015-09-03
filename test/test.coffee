assert = require('chai').assert
p = console.log

fp = require '../src/flipFP'


describe 'clone', ->
  it 'handles basic case', ->
    val = {a:1, b:{c:2}, d:[{e:3}], f:[4]}
    assert.deepEqual fp.clone(val), val
    assert.isFalse fp.clone(val) == val


describe 'keys', ->
  it 'handles handles basic case', ->
    val = {a:1, b:{c:2}, d:[{e:3}], f:[4]}
    assert.sameMembers fp.keys(val), ['a','b','d','f']


describe 'id', ->
  it 'handles handles basic case', ->
    val = {a:1, b:{c:2}, d:[{e:3}], f:[4]}
    assert.equal fp.id(val), val


describe 'map', ->
  it 'handles list of primitives', ->
    fn = fp.map (x) -> x+1
    assert.deepEqual (fn [1,2,3]), [2,3,4]

  it 'handles list of objects', ->      
    fn = fp.map (x) -> x._id += 1; x
    assert.deepEqual (fn [{_id:1}, {_id:2}]), [{_id:2}, {_id:3}]


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

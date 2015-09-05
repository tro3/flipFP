
x = module.exports
p = console.log

defers = []
  
  
#
#**_maybeUncurry** => (* -> *) -> (* -> *)
#
# Returns the curried function if passed a curried amount of parameters,
# and the executed function if passed more
#
_maybeUncurry = (fn1, fn2) ->
  () ->
    if arguments.length > fn1.length
      fn2.apply(null,arguments)
    else
      fn1.apply(null,arguments)


#
#**all** => (a -> Boolean) -> ([a] -> Boolean)
#
_all = (fn) ->
  (lst) ->
    for item in lst
      return false if !(fn item)
    true
_all2 = (fn, lst) -> _all(fn)(lst)    
x.all = all = _maybeUncurry _all, _all2


#
#**allPass** => [(a -> Boolean)] -> (a -> Boolean)
#
_allPass = (lst) ->
  (val) ->
    for fcn in lst
      return false if !(fcn val)
    true
_allPass2 = (lst, val) -> _allPass(lst)(val)    
x.allPass = allPass = _maybeUncurry _allPass, _allPass2


#
#**always** => a -> (* -> a)
#
x.always = always = (val) ->
  () -> val


#
#**any** => (a -> Boolean) -> ([a] -> Boolean)
#
_any = (fn) ->
  (lst) ->
    for item in lst
      return true if (fn item)
    false
_any2 = (fn, lst) -> _any(fn)(lst)    
x.any = any = _maybeUncurry _any, _any2


#
#**anyPass** => [(a -> Boolean)] -> (a -> Boolean)
#
_anyPass = (lst) ->
  (val) ->
    for fcn in lst
      return true if (fcn val)
    false
_anyPass2 = (lst, val) -> _anyPass(lst)(val)    
x.anyPass = anyPass = _maybeUncurry _anyPass, _anyPass2


#
#**chain** => (a -> []) -> ([a] -> [])
#
x.chain = chain = (fcn) ->
  (lst) ->
    result = []
    for item in lst
      for res in fcn(item)
        result.push res
    result


#
#**compose** => [(a -> a)] -> (a -> a)
#
x.compose = compose = ->
  fcns = []
  for item in arguments
    fcns.push item
  fcns = fcns.reverse()
  () ->
    val = fcns[0].apply(0, arguments)
    for fcn in fcns[1..]
      val = fcn(val)
    val  


#
#**concat** => []... -> []
#
x.concat = concat = () ->
  result = []
  for i in [0...arguments.length]
    list = arguments[i]
    list = [list] if !(list instanceof Array)
    for item in list
      result.push item
  result


#
#**composeP** => [(a -> a)] -> (a -> a)
#
x.composeP = composeP = ->
  _pipeP = (f1,f2) ->
    () -> f1.apply(0, arguments).then (x) -> f2(x)
  
  fcns = []
  for item in arguments
    fcns.push item
  fcns = fcns.reverse()
  q = fcns[0].apply(0, arguments)
  reduce(_pipeP, q, fcns[1..])
  
  
#
#**clone** => {} -> {}
#
defers.push ->
  x.clone = clone = traverseObj id,id,id


#
#**drop** => Int -> ([] -> {})
#
_drop = (n) ->
  (lst) ->
    r = []
    for i in [n...lst.length]
      r.push lst[i]
    r
_drop2 = (n, lst) -> _drop(n)(lst)
x.drop = drop = _maybeUncurry _drop, _drop2


#
#**filter** => (a -> a) -> ([] -> [])
#
_filter = (fcn) ->
  (lst) ->
    r = []
    for item in lst
      r.push item if fcn item
    r
_filter2 = (n, lst) -> _filter(n)(lst)
x.filter = filter = _maybeUncurry _filter, _filter2


#
#**id** => a -> a
#
x.id = id = (a) -> a


#
#**keys** => ({} -> [String])
#
x.keys = keys = (a) -> Object.keys a


#
#**map** => (a -> a) -> ([a] -> [a])
#
_map = (fcn) ->
  (lst) ->
    result = []
    for item in lst
      result.push fcn(item)
    result
_map2 = (fcn, lst) -> _map(fcn)(lst)
x.map = map = _maybeUncurry _map, _map2


#
#**mapIndex** => (a,Int -> a) -> ([a] -> [a])
#
_mapIndex = (fcn) ->
  (lst) ->
    result = []
    for i in [0...lst.length]
      result.push fcn(lst[i], i)
    result
_mapIndex2 = (fcn, lst) -> _mapIndex(fcn)(lst)
x.mapIndex = mapIndex = _maybeUncurry _mapIndex, _mapIndex2
  

#
#**mapObj** => (a -> a) -> ({} -> {})
#
x.mapObj = mapObj = (fcn) ->
  (obj) ->
    result = {}
    for key, item of obj
      result[key] = fcn(item)
    result


#
#**reduce** => (a -> a) -> ({} -> {})
#
x.reduce = reduce = () ->
  _reduce = (fcn, init, lst) ->
    acc = init
    for val in lst
      acc = fcn(acc, val)
    acc

  fcn = arguments[0]
  if arguments.length > 1
    init = arguments[1]
    (lst) -> _reduce(fcn, init, lst)
  else
    (init, lst) -> _reduce(fcn, init, lst)
    

#
#**pipe** => [(a -> a)] -> (a -> a)
#
x.pipe = pipe = ->
  fcns = []
  for item in arguments
    fcns.push item
  () ->
    val = fcns[0].apply(0, arguments)
    for fcn in fcns[1..]
      val = fcn(val)
    val


#
#**pipeP** => [(a -> a)] -> (a -> a)
#
x.pipeP = pipeP = ->
  _pipeP = (f1,f2) ->
    () -> f1.apply(0, arguments).then (x) -> f2(x)
  
  fcns = []
  for item in arguments
    fcns.push item
  q = fcns[0].apply(0, arguments)
  reduce(_pipeP, q, fcns[1..])


#
#**take** => Int -> ([] -> {})
#
_take = (n) ->
  (lst) ->
    r = []
    for i in [0...n]
      r.push lst[i]
    r
_take2 = (n, lst) -> _take(n)(lst)
x.take = take = _maybeUncurry _take, _take2


#
#**traverseObj** => (a -> a) -> ({} -> {}) -> ({} -> {}) -> ({} -> {})
#
# The first object function is executed before descending, the second operates
# on the object resulting after descending
#
x.traverseObj = traverseObj = (valFcn, preFcn, postFcn) ->
  loopFn = (val) ->
    if val instanceof Array then loopOverList val
    else if typeof val == 'object' then processObj val
    else valFcn val

  loopOverObj = mapObj loopFn
  loopOverList = _map loopFn
  
  processObj = pipe(
    preFcn
    loopOverObj
    postFcn
  )


#
#**zipObj** => [] -> ([] -> {})
#
_zip = (keys) ->
  (vals) ->
    r = {}
    for i in [0...keys.length]
      r[keys[i]] = vals[i]
    r
_zip2 = (keys, vals) -> _zip(keys)(vals)
x.zipObj = zipObj = _maybeUncurry _zip, _zip2


#
#**zipKeys** => (String -> a) -> ([String] -> {})
#
_zipKeys = (fcn) ->
  (keys) ->
    r = {}
    for key in keys
      r[key] = fcn key
    r
_zipKeys2 = (fcn, keys) -> _zipKeys(fcn)(keys)
x.zipKeys = zipKeys = _maybeUncurry _zipKeys, _zipKeys2



defers.forEach (fcn) -> fcn()


#Speed testing

#keys = ['a','b','c','d','e']
#vals = [1,2,3,4,5]
#f0 = _zip keys
#f1 = zip keys
#n=1000000
#
#t0 = Date.now()
#for i in [0...n]
#  f0 vals
#p Date.now() - t0
#
#t0 = Date.now()
#for i in [0...n]
#  f1 vals
#p Date.now() - t0
#
#t0 = Date.now()
#for i in [0...n]
#  zip keys, vals
#p Date.now() - t0


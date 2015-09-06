
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
#**splitAt** => Int -> ([] -> [[],[]])
#
_splitAt = (n) ->
  (lst) ->
    r1 = []
    r2 = []
    for i in [0...lst.length]
      if i < n then r1.push lst[i] else r2.push lst[i]
    [r1,r2]
_splitAt2 = (n, lst) -> _splitAt(n)(lst)
x.splitAt = splitAt = _maybeUncurry _splitAt, _splitAt2

#
#**_maybeUncurryOrPipe** => (* -> *) -> (* -> *)
#
# Returns the curried function if passed a curried amount of parameters,
# and the executed function if passed more
#
_maybeUncurryOrPipe = (fcn) ->
  n = fcn.length
  split = _splitAt n
  () ->
    if arguments.length > fcn.length
      [args1, args2] = split arguments  
      fn1 = fcn.apply(null, args1)
      if args2.length == 1 and typeof args2[0] == 'function'
        fn2 = args2[0]
        () -> fn1(fn2.apply(null,arguments))
      else
        fn1.apply(null,args2)
    else
      fcn.apply(null,arguments)

#
#**_maybePipe** => (* -> *) -> (* -> *)
#
# For one-param functions - Returns a piped function if passed
# a function as an argument, and the executed function if passed values
#
_maybePipe = (fn) ->
  () ->
    if arguments.length == 1 and typeof arguments[0] == 'function'
      p 'piped'
      fn2 = arguments[0]
      () -> fn(fn2.apply(null,arguments))
    else
      p 'not piped', arguments
      fn.apply(null,arguments)


#
#**all** => (a -> Boolean) -> ([a] -> Boolean)
#
_all = (fn) ->
  (lst) ->
    for item in lst
      return false if !(fn item)
    true
x.all = all = _maybeUncurryOrPipe _all


#
#**allPass** => [(a -> Boolean)] -> (a -> Boolean)
#
_allPass = (lst) ->
  (val) ->
    for fcn in lst
      return false if !(fcn val)
    true
x.allPass = allPass = _maybeUncurryOrPipe _allPass


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
#**callAll** => [(a -> a)] -> (a -> [])
#
_callAll = (fcns) ->
  (val) ->
    result = []
    for fcn in fcns
      result.push fcn val
    result
_callAll2 = (fcns, val) -> _callAll(fcns)(val)    
x.callAll = callAll = _maybeUncurry _callAll, _callAll2


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
#**filter** => (a -> Boolean) -> ([] -> [])
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
#**filterIndex** => (a,i -> Boolean) -> ([] -> [])
#
_filterIndex = (fcn) ->
  (lst) ->
    r = []
    for i in [0...lst.length]
      r.push lst[i] if fcn lst[i], i
    r
_filterIndex2 = (n, lst) -> _filterIndex(n)(lst)
x.filterIndex = filterIndex = _maybeUncurry _filterIndex, _filterIndex2


#
#**flatten** => [[]] -> []
#
_flatten = (lst) ->
  r = []
  for item in lst
    if item instanceof Array
      subs = _flatten item
      r = r.concat subs
    else r.push item
  r
x.flatten = flatten = _maybePipe _flatten


#
#**id** => a -> a
#
x.id = id = (a) -> a


#
#**init** => [] -> []
#
x.init = init = (lst) ->
    r = []
    for i in [0...lst.length-1]
      r.push lst[i]
    r


#
#**isNothing** => a -> Boolean
#
_isNothing = (a) ->
  return true if a in [null, undefined]
  return a.trim().length == 0 if typeof a == 'string'
  return Object.keys(a).length == 0 if typeof a == 'object' 
  return false
x.isNothing = isNothing = _maybePipe _isNothing


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
#**prop** => String -> ({} -> a)
#
_prop = (key) -> (obj) -> obj[key]
_prop2 = (key, obj) -> _prop(key)(obj)
x.prop = prop = _maybeUncurry _prop, _prop2


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
#**splitHead** => [a] -> [a,[]]
#
x.splitHead = splitHead = (lst) -> [lst[0], tail lst]


#
#**splitHead** => [a] -> [a,[]]
#
x.splitLast = splitLast = (lst) -> [init lst, lst[-1..-1]]


#
#**tail** => [] -> []
#
x.tail = tail = (lst) ->
    r = []
    for i in [1...lst.length]
      r.push lst[i]
    r


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
x.take = take = _maybeUncurryOrPipe _take


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

# 
#map = _maybeUncurryOrPipe _map
#
#add = (x) -> x + 1
#range = (x) -> [0...x]
#
#
#p 'compiling'
#
#mapAddA = _map add
#mapAddB = map add
#mapAddRange = map add, range
#
#
#p 'executing'
#
#
#p mapAddA(range(4))
#p mapAddRange(4)
#p mapAddB(range(4))
#p map add, range(4)
#
#
#m = 10
#n = 150000
#
#t0 = Date.now()
#for i in [0...n]
#  mapAddA(range(m))
#p Date.now() - t0
#
#t0 = Date.now()
#for i in [0...n]
#  mapAddRange(m)
#p Date.now() - t0
#
#t0 = Date.now()
#for i in [0...n]
#  mapAddB(range(m))
#p Date.now() - t0
#
#t0 = Date.now()
#for i in [0...n]
#  map add, range(m)
#p Date.now() - t0

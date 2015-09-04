
x = module.exports
p = console.log

defers = []
  
  
#
#**_maybeUncurry** => (* -> *) -> (* -> *)
#
# Returns the curried function if passed a curried amount of parameters,
# and the executed function if passed more
#
_maybeUncurry = (fn) ->
  () ->
    if arguments.length > fn.length
      fn.apply(null,[].slice.call(arguments, 0, fn.length))
        .apply(null,[].slice.call(arguments, fn.length, arguments.length))
    else fn.apply(null,arguments)


#
#**all** => (a -> Boolean) -> ([a] -> Boolean)
#
x.all = all = (fn) ->
  (lst) ->
    for item in lst
      return false if !(fn item)
    true

#
#**allPass** => [(a -> Boolean)] -> (a -> Boolean)
#
x.allPass = allPass = (lst) ->
  (val) ->
    for fcn in lst
      return false if !(fcn val)
    true


#
#**always** => a -> (* -> a)
#
x.always = always = (val) ->
  () -> val


#
#**any** => (a -> Boolean) -> ([a] -> Boolean)
#
x.any = any = (fn) ->
  (lst) ->
    for item in lst
      return true if (fn item)
    false


#
#**anyPass** => [(a -> Boolean)] -> (a -> Boolean)
#
x.anyPass = anyPass = (lst) ->
  (val) ->
    for fcn in lst
      return true if (fcn val)
    false


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
x.drop = drop = _maybeUncurry _drop


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
x.map = map = _maybeUncurry _map
  

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
x.take = take = _maybeUncurry _take


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
  loopOverList = map loopFn
  
  processObj = pipe(
    preFcn
    loopOverObj
    postFcn
  )


#
#**zip** => [] -> ([] -> {})
#
_zip = (keys) ->
  (vals) ->
    r = {}
    for i in [0...keys.length]
      r[keys[i]] = vals[i]
    r
x.zip = zip = _maybeUncurry _zip


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

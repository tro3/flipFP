
x = module.exports
p = console.log

defers = []


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
x.map = map = (fcn) ->
  (lst) ->
    result = []
    for item in lst
      result.push fcn(item)
    result


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


defers.forEach (fcn) -> fcn()

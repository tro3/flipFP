
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
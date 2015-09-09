
x = module.exports
p = console.log

defers = []

#
# Given a unary function f(x):
#
# It can be passed three things:
#
#   1. A value
#   2. A promise
#   3. Another function (which may return a value or a promise)
#
# Execute and pipe wrappers:
#
#   f'(x) = | x is value -> f(x)
#           | x is promise -> x.then((val) -> f(val))
#
#   f''(x) = | x is function g(y) -> h(y) = f'(g(y))
#            | otherwise f'(x)


  
  
  
# Internal piping functions
#
# Note that f1 is assumed to occur *before* f2
#

_isPromise = (x) -> x != null and typeof x == 'object' && 'then' of x

_pipe = (f1,f2) ->
  () ->
    x1 = f1.apply(null, arguments)
    if _isPromise x1
      x1.then (x2) -> f2(x2)
    else
      f2(x1)

_qPipe = (f1,f2) ->
  () -> f1.apply(null, arguments).then (x) -> f2(x)

  
# ## Normal Functions
#
#   Functions that do not operate on promises

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


# Remove the debug functions once stable
debug = false

#
#**maybePipe** => (* -> *) -> (* -> *) or a
#
# Returns the original function generator if passed the proper
# amount of parameters, and if passed more will returned the
# executed function unless there is only on extra param and a
# function is passed.  In that case, the fucnction passed will
# be piped to the generated function.
#
x.maybePipe = maybePipe = (fcn) ->
  n = fcn.length
  split = _splitAt n
  () ->
    if arguments.length > fcn.length
      [args1, args2] = split arguments  
      fn1 = fcn.apply(null, args1)
      if args2.length == 1 and typeof args2[0] == 'function'
        fn2 = args2[0]
        p 'piped and conditional' if debug
        maybePipeDirect _pipe(fn2,fn1)
      else if args2.length == 1 and _isPromise args2[0]
        p 'direct q' if debug
        args2[0].then (x) -> fn1(x)
      else
        p 'direct' if debug
        fn1.apply(null,args2)
    else
      fcn2 = fcn.apply(null,arguments)
      if fcn2.length == 1
        p 'conditional' if debug
        maybePipeDirect fcn2
      else
        p 'static' if debug
        fcn2


# Making up for the lack of export before maybePipe def'n
x.splitAt = splitAt = maybePipe _splitAt


#
#**maybePipeDirect** => (* -> *) -> (* -> *) or a
#
# Returns the executed original function if passed a value
# as an argument.  If passed a function, it will
# be piped to the original function.  Only works for
# single-argument functions
#
x.maybePipeDirect = maybePipeDirect = (fcn) ->
  (val) ->
    if typeof val == 'function'
      if val.length == 1
        p 'single piped and conditional' if debug
        maybePipeDirect _pipe(val,fcn)
      else
        p 'single piped' if debug
        _pipe(val,fcn)
    else if _isPromise val
      p 'single direct q' if debug
      val.then (x) -> fcn(x)
    else
      p 'single direct' if debug
      fcn(val)


#
#**all** => (a -> Boolean) -> ([a] -> Boolean)
#
_all = (fn) ->
  (lst) ->
    for item in lst
      return false if !(fn item)
    true
x.all = all = maybePipe _all


#
#**allPass** => [(a -> Boolean)] -> (a -> Boolean)
#
_allPass = (lst) ->
  (val) ->
    for fcn in lst
      return false if !(fcn val)
    true
x.allPass = allPass = maybePipe _allPass


#
#**always** => a -> (* -> a)
#
# Piping makes no sense
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
x.any = any = maybePipe _any


#
#**anyPass** => [(a -> Boolean)] -> (a -> Boolean)
#
_anyPass = (lst) ->
  (val) ->
    for fcn in lst
      return true if (fcn val)
    false
x.anyPass = anyPass = maybePipe _anyPass


#
#**callAll** => [(a -> a)] -> (a -> [])
#
_callAll = (fcns) ->
  (val) ->
    result = []
    for fcn in fcns
      result.push fcn val
    result
x.callAll = callAll = maybePipe _callAll


#
#**chain** => (a -> []) -> ([a] -> [])
#
_chain = (fcn) ->
  (lst) ->
    result = []
    for item in lst
      for res in fcn(item)
        result.push res
    result
x.chain = chain = maybePipe _chain


#
#**compose** => [(a -> a)] -> (a -> a)
#
# Can't be maybePipe'd due to unknown arg count
#
x.compose = compose = () ->
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
# Can't be maybePipe'd due to unknown arg count
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
x.drop = drop = maybePipe _drop


#
#**filter** => (a -> Boolean) -> ([] -> [])
#
_filter = (fcn) ->
  (lst) ->
    r = []
    for item in lst
      r.push item if fcn item
    r
x.filter = filter = maybePipe _filter


#
#**filterIndex** => (a,i -> Boolean) -> ([] -> [])
#
_filterIndex = (fcn) ->
  (lst) ->
    r = []
    for i in [0...lst.length]
      r.push lst[i] if fcn lst[i], i
    r
x.filterIndex = filterIndex = maybePipe _filterIndex


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
x.flatten = flatten = maybePipeDirect _flatten


#
#**id** => a -> a
#
x.id = id = (a) -> a


#
#**init** => [] -> []
#
_init = (lst) ->
    r = []
    for i in [0...lst.length-1]
      r.push lst[i]
    r
x.init = init = maybePipe _init


#
#**isNothing** => a -> Boolean
#
_isNothing = (a) ->
  return true if a in [null, undefined]
  return a.trim().length == 0 if typeof a == 'string'
  return Object.keys(a).length == 0 if typeof a == 'object' 
  return false
x.isNothing = isNothing = maybePipeDirect _isNothing


#
#**keys** => ({} -> [String])
#
_keys = (a) -> Object.keys a
x.keys = keys = maybePipeDirect _keys


#
#**map** => (a -> a) -> ([a] -> [a])
#
_map = (fcn) ->
  (lst) ->
    result = []
    for item in lst
      result.push fcn(item)
    result
x.map = map = maybePipe _map


#
#**mapIndex** => (a,Int -> a) -> ([a] -> [a])
#
_mapIndex = (fcn) ->
  (lst) ->
    result = []
    for i in [0...lst.length]
      result.push fcn(lst[i], i)
    result
x.mapIndex = mapIndex = maybePipe _mapIndex
  

#
#**mapObj** => (a -> a) -> ({} -> {})
#
_mapObj = (fcn) ->
  (obj) ->
    result = {}
    for key, item of obj
      result[key] = fcn(item)
    result
x.mapObj = mapObj = maybePipe _mapObj


#
#**pipe** => [(a -> a)] -> (a -> a)
#
# Can't be maybePipe'd due to unknown arg count
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
#**prop** => String -> ({} -> a)
#
_prop = (key) -> (obj) -> obj[key]
x.prop = prop = maybePipe _prop


#
#**reduce** => (b,a -> b) -> b -> ([a] -> b)
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
_splitHead = (lst) -> [lst[0], tail lst]
x.splitHead = splitHead = maybePipeDirect _splitHead


#
#**splitLast** => [a] -> [[],a]
#
_splitHead = (lst) -> [init lst, lst[-1..-1]]
x.splitLast = splitLast = maybePipeDirect _splitHead


#
#**tail** => [] -> []
#
_tail = (lst) ->
    r = []
    for i in [1...lst.length]
      r.push lst[i]
    r
x.tail = tail = maybePipeDirect _tail


#
#**take** => Int -> ([] -> {})
#
_take = (n) ->
  (lst) ->
    r = []
    for i in [0...n]
      r.push lst[i]
    r
x.take = take = maybePipe _take


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
x.zipObj = zipObj = maybePipe _zip


#
#**zipKeys** => (String -> a) -> ([String] -> {})
#
_zipKeys = (fcn) ->
  (keys) ->
    r = {}
    for key in keys
      r[key] = fcn key
    r
x.zipKeys = zipKeys = maybePipe _zipKeys


# ## Q Functions
#  Functions that operate on promises


#
#**maybeqQPipeDirect** => (* -> *) -> (* -> *) or a
#
# Returns the executed original function if passed a value
# as an argument.  If passed a function, it will
# be piped to the original function.  Only works for
# single-argument functions
#
x.maybeQPipeDirect = maybeQPipeDirect = (fcn) ->
  (val) ->
    if typeof val == 'function'
      if val.length == 1
        maybePipeDirect () ->
          fcn.apply(null, arguments)
          .then (x) -> val(x)
      else
        () -> fcn(val.apply(null,arguments))
    else
      fcn(val)
      

#
#**qCompose** => [(a -> Q a)] -> (a -> Q a)
#
# Can't be maybePipe'd due to unknown arg count
#
x.qCompose = qCompose = ->
  _qPipe = (f1,f2) ->
    () -> f1.apply(null, arguments).then (x) -> f2(x)
  
  fcns = []
  for item in arguments
    fcns.push item
  fcns = fcns.reverse()
  q = () -> fcns[0].apply(null, arguments)
  for fcn in fcns[1..]
    q = _qPipe(q, fcn)
  q



#
#**qPipe** => [(a -> Q a)] -> (a -> Q a)
#
# Can't be maybePipe'd due to unknown arg count
#
x.qPipe = qPipe = ->
  _qPipe = (f1,f2) ->
    () -> f1.apply(null, arguments).then (x) -> f2(x)
  
  fcns = []
  for item in arguments
    fcns.push item
  q = () -> fcns[0].apply(null, arguments)
  for fcn in fcns[1..]
    q = _qPipe(q, fcn)
  q
  
  


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
#map = maybePipe _map
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

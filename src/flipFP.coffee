Q = require 'q'
x = module.exports
p = console.log

defers = []

#
# Given a unary function f(x):
#
# It can be passed one of three things:
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
#   With f' we know we are executing
#
#
#   f''(x) = | x is function g(y) -> h(y) = f'(g(y))
#            | otherwise f'(x)
#
#   With f'' we may be compiling
#
#
#
#
# Given a function *generator* F(a,b,...) that generates a unary function f(x)
#
# It can be passed two quantities of parameters
#
#   a. The correct amount
#   b. The correct amount + 1, intending to execute the generated function
#
#   F'(a,b,...) = F(a,b,...)'' = f''
#   F'(a,b,...,x) = F(a,b,...)''(x) = f''(x)
# 


_isFunction = (x) -> typeof x == 'function'
_isPromise = (x) -> x != null and typeof x == 'object' && 'then' of x

    
# f'
_execWrap = (f) ->
  (x) ->
    if _isPromise x then x.then((y) -> f(y))          # exec promise
    else                 f(x)                         # exec primitive
  
      
# f''
x.pipeWrap = pipeWrap = (f) ->
  (g) ->
    if _isFunction g
      if g.length == 1
        pipeWrap () -> _execWrap(f)(g.apply(null, arguments))   # pipe unary function
      else
        () -> _execWrap(f)(g.apply(null, arguments))            # pipe function
    else
      _execWrap(f)(g)                                           # pipe value (promise or primitive)
  
  
# F'
_splitArgs = (n) -> (lst) -> [(lst[i] for i in [0...n]), lst[n]]
x.genWrap = genWrap = (F) ->
  n = F.length
  split = _splitArgs(n)
  () ->
    if arguments.length == n then pipeWrap F.apply(null, arguments)
    else if arguments.length == n+1
      [args, x] = split arguments
      f = F.apply(null, args)
      pipeWrap(f)(x)
    else throw new Error 'Incorrect argument count'
      
  
  
  



# ## Normal Functions
#
# Functions that do not generate promises


#
#**all** => (a -> Boolean) -> ([a] -> Boolean)
#
_all = (fn) ->
  (lst) ->
    for item in lst
      return false if !(fn item)
    true
x.all = all = genWrap _all


#
#**allPass** => [(a -> Boolean)] -> (a -> Boolean)
#
_allPass = (lst) ->
  (val) ->
    for fcn in lst
      return false if !(fcn val)
    true
x.allPass = allPass = genWrap _allPass


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
x.any = any = genWrap _any


#
#**anyPass** => [(a -> Boolean)] -> (a -> Boolean)
#
_anyPass = (lst) ->
  (val) ->
    for fcn in lst
      return true if (fcn val)
    false
x.anyPass = anyPass = genWrap _anyPass


#
#**callAll** => [(a -> a)] -> (a -> [])
#
_callAll = (fcns) ->
  (val) ->
    result = []
    for fcn in fcns
      result.push fcn val
    result
x.callAll = callAll = genWrap _callAll


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
x.chain = chain = genWrap _chain


#
#**compose** => [(a -> a)] -> (a -> a)
#
# Can't be genWrap'd due to unknown arg count
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
# Can't be genWrap'd due to unknown arg count
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
x.drop = drop = genWrap _drop


#
#**filter** => (a -> Boolean) -> ([] -> [])
#
_filter = (fcn) ->
  (lst) ->
    r = []
    for item in lst
      r.push item if fcn item
    r
x.filter = filter = genWrap _filter


#
#**filterIndex** => (a,i -> Boolean) -> ([] -> [])
#
_filterIndex = (fcn) ->
  (lst) ->
    r = []
    for i in [0...lst.length]
      r.push lst[i] if fcn lst[i], i
    r
x.filterIndex = filterIndex = genWrap _filterIndex


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
x.flatten = flatten = pipeWrap _flatten


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
x.init = init = genWrap _init


#
#**isNothing** => a -> Boolean
#
_isNothing = (a) ->
  return true if a in [null, undefined]
  return a.trim().length == 0 if typeof a == 'string'
  return Object.keys(a).length == 0 if typeof a == 'object' 
  return false
x.isNothing = isNothing = pipeWrap _isNothing


#
#**keys** => ({} -> [String])
#
_keys = (a) -> Object.keys a
x.keys = keys = pipeWrap _keys


#
#**map** => (a -> a) -> ([a] -> [a])
#
_map = (fcn) ->
  (lst) ->
    result = []
    for item in lst
      result.push fcn(item)
    result
x.map = map = genWrap _map


#
#**mapIndex** => (a,Int -> a) -> ([a] -> [a])
#
_mapIndex = (fcn) ->
  (lst) ->
    result = []
    for i in [0...lst.length]
      result.push fcn(lst[i], i)
    result
x.mapIndex = mapIndex = genWrap _mapIndex


#
#**mapKeys** => (String -> a) -> ([String] -> {})
#
_mapKeys = (fcn) ->
  (lst) ->
    result = {}
    for key in lst
      result[key] = fcn(key)
    result
x.mapKeys = mapKeys = genWrap _mapKeys


#
#**mapObj** => (a -> a) -> ({} -> {})
#
_mapObj = (fcn) ->
  (obj) ->
    result = {}
    for key, item of obj
      result[key] = fcn(item)
    result
x.mapObj = mapObj = genWrap _mapObj


#
#**merge** => {} -> ({} -> {})
#
#
defers.push ->
  _merge = (old) ->
    loopFn = (o, n) ->
      return o if n == undefined
      if n instanceof Array
        if o instanceof Array then loopOverList o, n
        else n
      else if typeof n == 'object'
        if typeof o == 'object' then loopOverObj o, n
      else n    
    loopOverList = (o,n) -> (loopFn(o[i],n[i]) for i in [0...n.length])  
    loopOverObj = (o,n) -> _mapKeys((k) -> loopFn(o[k],n[k]))(_union(_keys o)(_keys n))

    (new_) ->
      loopOverObj(old, new_)
      
  x.merge = merge = genWrap _merge
  

#
#**pipe** => [(a -> a)] -> (a -> a)
#
# Can't be genWrap'd due to unknown arg count
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
x.prop = prop = genWrap _prop


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
#**splitAt** => Int -> ([] -> [[],[]])
#
_splitAt = (n) ->
  (lst) ->
    r1 = []
    r2 = []
    for i in [0...lst.length]
      if i < n then r1.push lst[i] else r2.push lst[i]
    [r1,r2]
x.splitAt = splitAt = genWrap _splitAt


#
#**splitHead** => [a] -> [a,[]]
#
_splitHead = (lst) -> [lst[0], tail lst]
x.splitHead = splitHead = pipeWrap _splitHead


#
#**splitLast** => [a] -> [[],a]
#
_splitHead = (lst) -> [init lst, lst[-1..-1]]
x.splitLast = splitLast = pipeWrap _splitHead


#
#**tail** => [] -> []
#
_tail = (lst) ->
    r = []
    for i in [1...lst.length]
      r.push lst[i]
    r
x.tail = tail = pipeWrap _tail


#
#**take** => Int -> ([] -> {})
#
_take = (n) ->
  (lst) ->
    r = []
    for i in [0...n]
      r.push lst[i]
    r
x.take = take = genWrap _take


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
#**union** => [] -> ([] -> [])
#
_union = (olst) ->
  (nlst) ->
    r = (olst[i] for i in [0...olst.length])
    for i in [0...nlst.length]
      r.push nlst[i] if nlst[i] not in r
    r
x.union = union = genWrap _union


#
#**zipObj** => [] -> ([] -> {})
#
_zip = (keys) ->
  (vals) ->
    r = {}
    for i in [0...keys.length]
      r[keys[i]] = vals[i]
    r
x.zipObj = zipObj = genWrap _zip


#
#**zipKeys** => (String -> a) -> ([String] -> {})
#
_zipKeys = (fcn) ->
  (keys) ->
    r = {}
    for key in keys
      r[key] = fcn key
    r
x.zipKeys = zipKeys = genWrap _zipKeys


# ## Q Functions
#  Functions that operate on promises


#
#**qCompose** => [(a -> Q a)] -> (a -> Q a)
#
# Can't be genWrap'd due to unknown arg count
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
#**qFilter** => (a -> Q Boolean) -> ([] -> Q [])
#
_qFilter = (fcn) ->
  (lst) ->
    qs = []
    r = []
    [0...lst.length].forEach (i) ->
      qs.push fcn(lst[i]).then((b) -> r[i] = b)
    Q.all(qs).then -> _filterIndex((b,i)->r[i])(lst)
x.qFilter = qFilter = genWrap _qFilter



#
#**qPipe** => [(a -> Q a)] -> (a -> Q a)
#
# Can't be genWrap'd due to unknown arg count
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

#_splitLast = (n) -> (lst) -> [(lst[i] for i in [0...n-1]), lst[n-1]]
#_apply = (f, args, x) -> xs = (args[i] for i in [0...args.length]); xs.push x; f.apply(null, xs)
#_pApply = (f, args) -> (x) -> _apply(f, args, x)
#altPipeWrap = (f) ->
#  split = _splitLast f.length
#  () ->
#    [args, g] = split arguments
#    if _isFunction g
#      altPipeWrap () -> _apply f, args, g.apply(null, arguments)
#    else if g == undefined and f.length > 0
#      altPipeWrap (x) -> _apply f, args, x
#    else if _isPromise g
#      g.then (val) -> _apply f, args, val 
#    else
#      _apply f, args, g
#      
#
#_map2 = (fcn, lst) ->
#  result = []
#  for item in lst
#    result.push fcn(item)
#  result
#
#
#_filter2 = (fcn, lst) ->
#  r = []
#  for item in lst
#    r.push item if fcn item
#  r
#
#
#data = [33..122]
#f = String.fromCharCode
#flt = (x) -> x < "b"
#
#n = 1500000
#
#test = (fcn) -> 
#  t0 = Date.now()
#  for i in [0...n]
#    fcn()
#  p Date.now() - t0
#
#
#f1 = filter flt, map f
#p f1 [66,67,68]
#test (-> f1 data)
#
#f1 = (x) -> _filter2 flt, _map2 f, x
#p f1 [66,67,68]
#test (-> f1 data)


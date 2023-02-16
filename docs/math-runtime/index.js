(function dartProgram(){function copyProperties(a,b){var t=Object.keys(a)
for(var s=0;s<t.length;s++){var r=t[s]
b[r]=a[r]}}function mixinPropertiesHard(a,b){var t=Object.keys(a)
for(var s=0;s<t.length;s++){var r=t[s]
if(!b.hasOwnProperty(r))b[r]=a[r]}}function mixinPropertiesEasy(a,b){Object.assign(b,a)}var z=function(){var t=function(){}
t.prototype={p:{}}
var s=new t()
if(!(s.__proto__&&s.__proto__.p===t.prototype.p))return false
try{if(typeof navigator!="undefined"&&typeof navigator.userAgent=="string"&&navigator.userAgent.indexOf("Chrome/")>=0)return true
if(typeof version=="function"&&version.length==0){var r=version()
if(/^\d+\.\d+\.\d+\.\d+$/.test(r))return true}}catch(q){}return false}()
function inherit(a,b){a.prototype.constructor=a
a.prototype["$i"+a.name]=a
if(b!=null){if(z){a.prototype.__proto__=b.prototype
return}var t=Object.create(b.prototype)
copyProperties(a.prototype,t)
a.prototype=t}}function inheritMany(a,b){for(var t=0;t<b.length;t++)inherit(b[t],a)}function mixinEasy(a,b){mixinPropertiesEasy(b.prototype,a.prototype)
a.prototype.constructor=a}function mixinHard(a,b){mixinPropertiesHard(b.prototype,a.prototype)
a.prototype.constructor=a}function lazyOld(a,b,c,d){var t=a
a[b]=t
a[c]=function(){a[c]=function(){A.hk(b)}
var s
var r=d
try{if(a[b]===t){s=a[b]=r
s=a[b]=d()}else s=a[b]}finally{if(s===r)a[b]=null
a[c]=function(){return this[b]}}return s}}function lazy(a,b,c,d){var t=a
a[b]=t
a[c]=function(){if(a[b]===t)a[b]=d()
a[c]=function(){return this[b]}
return a[b]}}function lazyFinal(a,b,c,d){var t=a
a[b]=t
a[c]=function(){if(a[b]===t){var s=d()
if(a[b]!==t)A.hl(b)
a[b]=s}var r=a[b]
a[c]=function(){return r}
return r}}function makeConstList(a){a.immutable$list=Array
a.fixed$length=Array
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var t=0;t<a.length;++t)convertToFastObject(a[t])}var y=0
function instanceTearOffGetter(a,b){var t=null
return a?function(c){if(t===null)t=A.di(b)
return new t(c,this)}:function(){if(t===null)t=A.di(b)
return new t(this,null)}}function staticTearOffGetter(a){var t=null
return function(){if(t===null)t=A.di(a).prototype
return t}}var x=0
function tearOffParameters(a,b,c,d,e,f,g,h,i,j){if(typeof h=="number")h+=x
return{co:a,iS:b,iI:c,rC:d,dV:e,cs:f,fs:g,fT:h,aI:i||0,nDA:j}}function installStaticTearOff(a,b,c,d,e,f,g,h){var t=tearOffParameters(a,true,false,c,d,e,f,g,h,false)
var s=staticTearOffGetter(t)
a[b]=s}function installInstanceTearOff(a,b,c,d,e,f,g,h,i,j){c=!!c
var t=tearOffParameters(a,false,c,d,e,f,g,h,i,!!j)
var s=instanceTearOffGetter(c,t)
a[b]=s}function setOrUpdateInterceptorsByTag(a){var t=v.interceptorsByTag
if(!t){v.interceptorsByTag=a
return}copyProperties(a,t)}function setOrUpdateLeafTags(a){var t=v.leafTags
if(!t){v.leafTags=a
return}copyProperties(a,t)}function updateTypes(a){var t=v.types
var s=t.length
t.push.apply(t,a)
return s}function updateHolder(a,b){copyProperties(b,a)
return a}var hunkHelpers=function(){var t=function(a,b,c,d,e){return function(f,g,h,i){return installInstanceTearOff(f,g,a,b,c,d,[h],i,e,false)}},s=function(a,b,c,d){return function(e,f,g,h){return installStaticTearOff(e,f,a,b,c,[g],h,d)}}
return{inherit:inherit,inheritMany:inheritMany,mixin:mixinEasy,mixinHard:mixinHard,installStaticTearOff:installStaticTearOff,installInstanceTearOff:installInstanceTearOff,_instance_0u:t(0,0,null,["$0"],0),_instance_1u:t(0,1,null,["$1"],0),_instance_2u:t(0,2,null,["$2"],0),_instance_0i:t(1,0,null,["$0"],0),_instance_1i:t(1,1,null,["$1"],0),_instance_2i:t(1,2,null,["$2"],0),_static_0:s(0,null,["$0"],0),_static_1:s(1,null,["$1"],0),_static_2:s(2,null,["$2"],0),makeConstList:makeConstList,lazy:lazy,lazyFinal:lazyFinal,lazyOld:lazyOld,updateHolder:updateHolder,convertToFastObject:convertToFastObject,updateTypes:updateTypes,setOrUpdateInterceptorsByTag:setOrUpdateInterceptorsByTag,setOrUpdateLeafTags:setOrUpdateLeafTags}}()
function initializeDeferredHunk(a){x=v.types.length
a(hunkHelpers,v,w,$)}var A={d3:function d3(){},
e7(a,b,c){return a},
eL(){return new A.ae("No element")},
eM(){return new A.ae("Too many elements")},
bm:function bm(a){this.a=a},
at:function at(){},
aC:function aC(){},
aD:function aD(a,b){var _=this
_.a=a
_.b=b
_.c=0
_.d=null},
a3:function a3(a,b,c){this.a=a
this.b=b
this.$ti=c},
a5:function a5(a,b,c){this.a=a
this.b=b
this.$ti=c},
bE:function bE(a,b){this.a=a
this.b=b},
eh(a){var t=v.mangledGlobalNames[a]
if(t!=null)return t
return"minified:"+a},
hb(a,b){var t
if(b!=null){t=b.x
if(t!=null)return t}return u.p.b(a)},
l(a){var t
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
t=J.H(a)
return t},
bs(a){var t,s=$.dG
if(s==null)s=$.dG=Symbol("identityHashCode")
t=a[s]
if(t==null){t=Math.random()*0x3fffffff|0
a[s]=t}return t},
dH(a,b){var t,s=/^\s*[+-]?((0x[a-f0-9]+)|(\d+)|([a-z0-9]+))\s*$/i.exec(a)
if(s==null)return null
t=s[3]
if(t!=null)return parseInt(a,10)
if(s[2]!=null)return parseInt(a,16)
return null},
eV(a){var t,s
if(!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(a))return null
t=parseFloat(a)
if(isNaN(t)){s=B.d.ar(a)
if(s==="NaN"||s==="+NaN"||s==="-NaN")return t
return null}return t},
ci(a){return A.eU(a)},
eU(a){var t,s,r,q
if(a instanceof A.n)return A.y(A.bZ(a),null)
t=J.ao(a)
if(t===B.G||t===B.I||u.o.b(a)){s=B.t(a)
if(s!=="Object"&&s!=="")return s
r=a.constructor
if(typeof r=="function"){q=r.name
if(typeof q=="string"&&q!=="Object"&&q!=="")return q}}return A.y(A.bZ(a),null)},
bY(a,b){var t,s="index"
if(!A.bV(b))return new A.S(!0,b,s,null)
t=J.aq(a)
if(b<0||b>=t)return A.c6(b,t,a,s)
return A.eW(b,s)},
b(a){var t,s
if(a==null)a=new A.bq()
t=new Error()
t.dartException=a
s=A.hm
if("defineProperty" in Object){Object.defineProperty(t,"message",{get:s})
t.name=""}else t.toString=s
return t},
hm(){return J.H(this.dartException)},
M(a){throw A.b(a)},
dn(a){throw A.b(A.T(a))},
O(a){var t,s,r,q,p,o
a=A.hi(a.replace(String({}),"$receiver$"))
t=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(t==null)t=A.a([],u.s)
s=t.indexOf("\\$arguments\\$")
r=t.indexOf("\\$argumentsExpr\\$")
q=t.indexOf("\\$expr\\$")
p=t.indexOf("\\$method\\$")
o=t.indexOf("\\$receiver\\$")
return new A.cn(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),s,r,q,p,o)},
co(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(t){return t.message}}(a)},
dN(a){return function($expr$){try{$expr$.$method$}catch(t){return t.message}}(a)},
d4(a,b){var t=b==null,s=t?null:b.method
return new A.bl(a,s,t?null:b.receiver)},
ap(a){if(a==null)return new A.cf(a)
if(typeof a!=="object")return a
if("dartException" in a)return A.a7(a,a.dartException)
return A.fR(a)},
a7(a,b){if(u.R.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
fR(a){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f=null
if(!("message" in a))return a
t=a.message
if("number" in a&&typeof a.number=="number"){s=a.number
r=s&65535
if((B.l.aW(s,16)&8191)===10)switch(r){case 438:return A.a7(a,A.d4(A.l(t)+" (Error "+r+")",f))
case 445:case 5007:q=A.l(t)
return A.a7(a,new A.aG(q+" (Error "+r+")",f))}}if(a instanceof TypeError){p=$.ej()
o=$.ek()
n=$.el()
m=$.em()
l=$.ep()
k=$.eq()
j=$.eo()
$.en()
i=$.es()
h=$.er()
g=p.B(t)
if(g!=null)return A.a7(a,A.d4(t,g))
else{g=o.B(t)
if(g!=null){g.method="call"
return A.a7(a,A.d4(t,g))}else{g=n.B(t)
if(g==null){g=m.B(t)
if(g==null){g=l.B(t)
if(g==null){g=k.B(t)
if(g==null){g=j.B(t)
if(g==null){g=m.B(t)
if(g==null){g=i.B(t)
if(g==null){g=h.B(t)
q=g!=null}else q=!0}else q=!0}else q=!0}else q=!0}else q=!0}else q=!0}else q=!0
if(q)return A.a7(a,new A.aG(t,g==null?f:g.method))}}return A.a7(a,new A.bB(typeof t=="string"?t:""))}if(a instanceof RangeError){if(typeof t=="string"&&t.indexOf("call stack")!==-1)return new A.aK()
t=function(b){try{return String(b)}catch(e){}return null}(a)
return A.a7(a,new A.S(!1,f,f,typeof t=="string"?t.replace(/^RangeError:\s*/,""):t))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof t=="string"&&t==="too much recursion")return new A.aK()
return a},
h2(a){var t
if(a==null)return new A.bO(a)
t=a.$cachedTrace
if(t!=null)return t
return a.$cachedTrace=new A.bO(a)},
hh(a){if(a==null||typeof a!="object")return J.c_(a)
else return A.bs(a)},
ha(a,b,c,d,e,f){switch(b){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw A.b(A.f("Unsupported number of arguments for wrapped closure"))},
bX(a,b){var t
if(a==null)return null
t=a.$identity
if(!!t)return t
t=function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,A.ha)
a.$identity=t
return t},
eG(a1){var t,s,r,q,p,o,n,m,l,k,j=a1.co,i=a1.iS,h=a1.iI,g=a1.nDA,f=a1.aI,e=a1.fs,d=a1.cs,c=e[0],b=d[0],a=j[c],a0=a1.fT
a0.toString
t=i?Object.create(new A.ck().constructor.prototype):Object.create(new A.as(null,null).constructor.prototype)
t.$initialize=t.constructor
if(i)s=function static_tear_off(){this.$initialize()}
else s=function tear_off(a2,a3){this.$initialize(a2,a3)}
t.constructor=s
s.prototype=t
t.$_name=c
t.$_target=a
r=!i
if(r)q=A.dv(c,a,h,g)
else{t.$static_name=c
q=a}t.$S=A.eC(a0,i,h)
t[b]=q
for(p=q,o=1;o<e.length;++o){n=e[o]
if(typeof n=="string"){m=j[n]
l=n
n=m}else l=""
k=d[o]
if(k!=null){if(r)n=A.dv(l,n,h,g)
t[k]=n}if(o===f)p=n}t.$C=p
t.$R=a1.rC
t.$D=a1.dV
return s},
eC(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.b("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.eA)}throw A.b("Error in functionType of tearoff")},
eD(a,b,c,d){var t=A.du
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,t)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,t)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,t)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,t)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,t)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,t)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,t)}},
dv(a,b,c,d){var t,s
if(c)return A.eF(a,b,d)
t=b.length
s=A.eD(t,d,a,b)
return s},
eE(a,b,c,d){var t=A.du,s=A.eB
switch(b?-1:a){case 0:throw A.b(new A.bt("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,s,t)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,s,t)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,s,t)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,s,t)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,s,t)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,s,t)
default:return function(e,f,g){return function(){var r=[g(this)]
Array.prototype.push.apply(r,arguments)
return e.apply(f(this),r)}}(d,s,t)}},
eF(a,b,c){var t,s
if($.ds==null)$.ds=A.dr("interceptor")
if($.dt==null)$.dt=A.dr("receiver")
t=b.length
s=A.eE(t,c,a,b)
return s},
di(a){return A.eG(a)},
eA(a,b){return A.cI(v.typeUniverse,A.bZ(a.a),b)},
du(a){return a.a},
eB(a){return a.b},
dr(a){var t,s,r,q=new A.as("receiver","interceptor"),p=J.eN(Object.getOwnPropertyNames(q))
for(t=p.length,s=0;s<t;++s){r=p[s]
if(q[r]===a)return r}throw A.b(A.ez("Field name "+a+" not found.",null))},
hk(a){throw A.b(new A.be(a))},
h1(a){return v.getIsolateTag(a)},
i2(a,b,c){Object.defineProperty(a,b,{value:c,enumerable:false,writable:true,configurable:true})},
hd(a){var t,s,r,q,p,o=$.ea.$1(a),n=$.cN[o]
if(n!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:n,enumerable:false,writable:true,configurable:true})
return n.i}t=$.cS[o]
if(t!=null)return t
s=v.interceptorsByTag[o]
if(s==null){r=$.e5.$2(a,o)
if(r!=null){n=$.cN[r]
if(n!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:n,enumerable:false,writable:true,configurable:true})
return n.i}t=$.cS[r]
if(t!=null)return t
s=v.interceptorsByTag[r]
o=r}}if(s==null)return null
t=s.prototype
q=o[0]
if(q==="!"){n=A.cY(t)
$.cN[o]=n
Object.defineProperty(a,v.dispatchPropertyName,{value:n,enumerable:false,writable:true,configurable:true})
return n.i}if(q==="~"){$.cS[o]=t
return t}if(q==="-"){p=A.cY(t)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:p,enumerable:false,writable:true,configurable:true})
return p.i}if(q==="+")return A.ee(a,t)
if(q==="*")throw A.b(A.dO(o))
if(v.leafTags[o]===true){p=A.cY(t)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:p,enumerable:false,writable:true,configurable:true})
return p.i}else return A.ee(a,t)},
ee(a,b){var t=Object.getPrototypeOf(a)
Object.defineProperty(t,v.dispatchPropertyName,{value:J.dl(b,t,null,null),enumerable:false,writable:true,configurable:true})
return b},
cY(a){return J.dl(a,!1,null,!!a.$ibk)},
hf(a,b,c){var t=b.prototype
if(v.leafTags[a]===true)return A.cY(t)
else return J.dl(t,c,null,null)},
h7(){if(!0===$.dk)return
$.dk=!0
A.h8()},
h8(){var t,s,r,q,p,o,n,m
$.cN=Object.create(null)
$.cS=Object.create(null)
A.h6()
t=v.interceptorsByTag
s=Object.getOwnPropertyNames(t)
if(typeof window!="undefined"){window
r=function(){}
for(q=0;q<s.length;++q){p=s[q]
o=$.ef.$1(p)
if(o!=null){n=A.hf(p,t[p],o)
if(n!=null){Object.defineProperty(o,v.dispatchPropertyName,{value:n,enumerable:false,writable:true,configurable:true})
r.prototype=o}}}}for(q=0;q<s.length;++q){p=s[q]
if(/^[A-Za-z_]/.test(p)){m=t[p]
t["!"+p]=m
t["~"+p]=m
t["-"+p]=m
t["+"+p]=m
t["*"+p]=m}}},
h6(){var t,s,r,q,p,o,n=B.A()
n=A.an(B.B,A.an(B.C,A.an(B.u,A.an(B.u,A.an(B.D,A.an(B.E,A.an(B.F(B.t),n)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){t=dartNativeDispatchHooksTransformer
if(typeof t=="function")t=[t]
if(t.constructor==Array)for(s=0;s<t.length;++s){r=t[s]
if(typeof r=="function")n=r(n)||n}}q=n.getTag
p=n.getUnknownTag
o=n.prototypeForTag
$.ea=new A.cP(q)
$.e5=new A.cQ(p)
$.ef=new A.cR(o)},
an(a,b){return a(b)||b},
hj(a,b,c){var t=a.indexOf(b,c)
return t>=0},
hi(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
cn:function cn(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
aG:function aG(a,b){this.a=a
this.b=b},
bl:function bl(a,b,c){this.a=a
this.b=b
this.c=c},
bB:function bB(a){this.a=a},
cf:function cf(a){this.a=a},
bO:function bO(a){this.a=a
this.b=null},
a9:function a9(){},
c0:function c0(){},
c1:function c1(){},
cm:function cm(){},
ck:function ck(){},
as:function as(a,b){this.a=a
this.b=b},
bt:function bt(a){this.a=a},
az:function az(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
ca:function ca(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
aA:function aA(a,b){this.a=a
this.$ti=b},
bn:function bn(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
cP:function cP(a){this.a=a},
cQ:function cQ(a){this.a=a},
cR:function cR(a){this.a=a},
dJ(a,b){var t=b.c
return t==null?b.c=A.dd(a,b.y,!0):t},
dI(a,b){var t=b.c
return t==null?b.c=A.aZ(a,"dz",[b.y]):t},
dK(a){var t=a.x
if(t===6||t===7||t===8)return A.dK(a.y)
return t===12||t===13},
eZ(a){return a.at},
e8(a){return A.de(v.typeUniverse,a,!1)},
Y(a,b,c,a0){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=b.x
switch(d){case 5:case 1:case 2:case 3:case 4:return b
case 6:t=b.y
s=A.Y(a,t,c,a0)
if(s===t)return b
return A.dX(a,s,!0)
case 7:t=b.y
s=A.Y(a,t,c,a0)
if(s===t)return b
return A.dd(a,s,!0)
case 8:t=b.y
s=A.Y(a,t,c,a0)
if(s===t)return b
return A.dW(a,s,!0)
case 9:r=b.z
q=A.b3(a,r,c,a0)
if(q===r)return b
return A.aZ(a,b.y,q)
case 10:p=b.y
o=A.Y(a,p,c,a0)
n=b.z
m=A.b3(a,n,c,a0)
if(o===p&&m===n)return b
return A.db(a,o,m)
case 12:l=b.y
k=A.Y(a,l,c,a0)
j=b.z
i=A.fO(a,j,c,a0)
if(k===l&&i===j)return b
return A.dV(a,k,i)
case 13:h=b.z
a0+=h.length
g=A.b3(a,h,c,a0)
p=b.y
o=A.Y(a,p,c,a0)
if(g===h&&o===p)return b
return A.dc(a,o,g,!0)
case 14:f=b.y
if(f<a0)return b
e=c[f-a0]
if(e==null)return b
return e
default:throw A.b(A.bc("Attempted to substitute unexpected RTI kind "+d))}},
b3(a,b,c,d){var t,s,r,q,p=b.length,o=A.cJ(p)
for(t=!1,s=0;s<p;++s){r=b[s]
q=A.Y(a,r,c,d)
if(q!==r)t=!0
o[s]=q}return t?o:b},
fP(a,b,c,d){var t,s,r,q,p,o,n=b.length,m=A.cJ(n)
for(t=!1,s=0;s<n;s+=3){r=b[s]
q=b[s+1]
p=b[s+2]
o=A.Y(a,p,c,d)
if(o!==p)t=!0
m.splice(s,3,r,q,o)}return t?m:b},
fO(a,b,c,d){var t,s=b.a,r=A.b3(a,s,c,d),q=b.b,p=A.b3(a,q,c,d),o=b.c,n=A.fP(a,o,c,d)
if(r===s&&p===q&&n===o)return b
t=new A.bJ()
t.a=r
t.b=p
t.c=n
return t},
a(a,b){a[v.arrayRti]=b
return a},
fW(a){var t,s=a.$S
if(s!=null){if(typeof s=="number")return A.h3(s)
t=a.$S()
return t}return null},
eb(a,b){var t
if(A.dK(b))if(a instanceof A.a9){t=A.fW(a)
if(t!=null)return t}return A.bZ(a)},
bZ(a){var t
if(a instanceof A.n){t=a.$ti
return t!=null?t:A.df(a)}if(Array.isArray(a))return A.bU(a)
return A.df(J.ao(a))},
bU(a){var t=a[v.arrayRti],s=u.b
if(t==null)return s
if(t.constructor!==s.constructor)return s
return t},
al(a){var t=a.$ti
return t!=null?t:A.df(a)},
df(a){var t=a.constructor,s=t.$ccache
if(s!=null)return s
return A.fx(a,t)},
fx(a,b){var t=a instanceof A.a9?a.__proto__.__proto__.constructor:b,s=A.fn(v.typeUniverse,t.name)
b.$ccache=s
return s},
h3(a){var t,s=v.types,r=s[a]
if(typeof r=="string"){t=A.de(v.typeUniverse,r,!1)
s[a]=t
return t}return r},
fw(a){var t,s,r,q,p=this
if(p===u.K)return A.ak(p,a,A.fB)
if(!A.R(p))if(!(p===u._))t=!1
else t=!0
else t=!0
if(t)return A.ak(p,a,A.fF)
t=p.x
s=t===6?p.y:p
if(s===u.r)r=A.bV
else if(s===u.i||s===u.H)r=A.fA
else if(s===u.N)r=A.fD
else r=s===u.v?A.e2:null
if(r!=null)return A.ak(p,a,r)
if(s.x===9){q=s.y
if(s.z.every(A.hc)){p.r="$i"+q
if(q==="eQ")return A.ak(p,a,A.fz)
return A.ak(p,a,A.fE)}}else if(t===7)return A.ak(p,a,A.fu)
return A.ak(p,a,A.fs)},
ak(a,b,c){a.b=c
return a.b(b)},
fv(a){var t,s=this,r=A.fr
if(!A.R(s))if(!(s===u._))t=!1
else t=!0
else t=!0
if(t)r=A.fq
else if(s===u.K)r=A.fp
else{t=A.b5(s)
if(t)r=A.ft}s.a=r
return s.a(a)},
bW(a){var t,s=a.x
if(!A.R(a))if(!(a===u._))if(!(a===u.A))if(s!==7)if(!(s===6&&A.bW(a.y)))t=s===8&&A.bW(a.y)||a===u.P||a===u.T
else t=!0
else t=!0
else t=!0
else t=!0
else t=!0
return t},
fs(a){var t=this
if(a==null)return A.bW(t)
return A.q(v.typeUniverse,A.eb(a,t),null,t,null)},
fu(a){if(a==null)return!0
return this.y.b(a)},
fE(a){var t,s=this
if(a==null)return A.bW(s)
t=s.r
if(a instanceof A.n)return!!a[t]
return!!J.ao(a)[t]},
fz(a){var t,s=this
if(a==null)return A.bW(s)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
t=s.r
if(a instanceof A.n)return!!a[t]
return!!J.ao(a)[t]},
fr(a){var t,s=this
if(a==null){t=A.b5(s)
if(t)return a}else if(s.b(a))return a
A.e0(a,s)},
ft(a){var t=this
if(a==null)return a
else if(t.b(a))return a
A.e0(a,t)},
e0(a,b){throw A.b(A.fc(A.dP(a,A.eb(a,b),A.y(b,null))))},
dP(a,b,c){var t=A.c4(a)
return t+": type '"+A.y(b==null?A.bZ(a):b,null)+"' is not a subtype of type '"+c+"'"},
fc(a){return new A.aX("TypeError: "+a)},
v(a,b){return new A.aX("TypeError: "+A.dP(a,null,b))},
fB(a){return a!=null},
fp(a){if(a!=null)return a
throw A.b(A.v(a,"Object"))},
fF(a){return!0},
fq(a){return a},
e2(a){return!0===a||!1===a},
hQ(a){if(!0===a)return!0
if(!1===a)return!1
throw A.b(A.v(a,"bool"))},
hS(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.b(A.v(a,"bool"))},
hR(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.b(A.v(a,"bool?"))},
hT(a){if(typeof a=="number")return a
throw A.b(A.v(a,"double"))},
hV(a){if(typeof a=="number")return a
if(a==null)return a
throw A.b(A.v(a,"double"))},
hU(a){if(typeof a=="number")return a
if(a==null)return a
throw A.b(A.v(a,"double?"))},
bV(a){return typeof a=="number"&&Math.floor(a)===a},
e_(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.b(A.v(a,"int"))},
hX(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.b(A.v(a,"int"))},
hW(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.b(A.v(a,"int?"))},
fA(a){return typeof a=="number"},
hY(a){if(typeof a=="number")return a
throw A.b(A.v(a,"num"))},
i_(a){if(typeof a=="number")return a
if(a==null)return a
throw A.b(A.v(a,"num"))},
hZ(a){if(typeof a=="number")return a
if(a==null)return a
throw A.b(A.v(a,"num?"))},
fD(a){return typeof a=="string"},
Q(a){if(typeof a=="string")return a
throw A.b(A.v(a,"String"))},
i1(a){if(typeof a=="string")return a
if(a==null)return a
throw A.b(A.v(a,"String"))},
i0(a){if(typeof a=="string")return a
if(a==null)return a
throw A.b(A.v(a,"String?"))},
e4(a,b){var t,s,r
for(t="",s="",r=0;r<a.length;++r,s=", ")t+=s+A.y(a[r],b)
return t},
fI(a,b){var t,s,r,q,p,o,n=a.y,m=a.z
if(""===n)return"("+A.e4(m,b)+")"
t=m.length
s=n.split(",")
r=s.length-t
for(q="(",p="",o=0;o<t;++o,p=", "){q+=p
if(r===0)q+="{"
q+=A.y(m[o],b)
if(r>=0)q+=" "+s[r];++r}return q+"})"},
e1(a2,a3,a4){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1=", "
if(a4!=null){t=a4.length
if(a3==null){a3=A.a([],u.s)
s=null}else s=a3.length
r=a3.length
for(q=t;q>0;--q)a3.push("T"+(r+q))
for(p=u.X,o=u._,n="<",m="",q=0;q<t;++q,m=a1){n=B.d.M(n+m,a3[a3.length-1-q])
l=a4[q]
k=l.x
if(!(k===2||k===3||k===4||k===5||l===p))if(!(l===o))j=!1
else j=!0
else j=!0
if(!j)n+=" extends "+A.y(l,a3)}n+=">"}else{n=""
s=null}p=a2.y
i=a2.z
h=i.a
g=h.length
f=i.b
e=f.length
d=i.c
c=d.length
b=A.y(p,a3)
for(a="",a0="",q=0;q<g;++q,a0=a1)a+=a0+A.y(h[q],a3)
if(e>0){a+=a0+"["
for(a0="",q=0;q<e;++q,a0=a1)a+=a0+A.y(f[q],a3)
a+="]"}if(c>0){a+=a0+"{"
for(a0="",q=0;q<c;q+=3,a0=a1){a+=a0
if(d[q+1])a+="required "
a+=A.y(d[q+2],a3)+" "+d[q]}a+="}"}if(s!=null){a3.toString
a3.length=s}return n+"("+a+") => "+b},
y(a,b){var t,s,r,q,p,o,n=a.x
if(n===5)return"erased"
if(n===2)return"dynamic"
if(n===3)return"void"
if(n===1)return"Never"
if(n===4)return"any"
if(n===6){t=A.y(a.y,b)
return t}if(n===7){s=a.y
t=A.y(s,b)
r=s.x
return(r===12||r===13?"("+t+")":t)+"?"}if(n===8)return"FutureOr<"+A.y(a.y,b)+">"
if(n===9){q=A.fQ(a.y)
p=a.z
return p.length>0?q+("<"+A.e4(p,b)+">"):q}if(n===11)return A.fI(a,b)
if(n===12)return A.e1(a,b,null)
if(n===13)return A.e1(a.y,b,a.z)
if(n===14){o=a.y
return b[b.length-1-o]}return"?"},
fQ(a){var t=v.mangledGlobalNames[a]
if(t!=null)return t
return"minified:"+a},
fo(a,b){var t=a.tR[b]
for(;typeof t=="string";)t=a.tR[t]
return t},
fn(a,b){var t,s,r,q,p,o=a.eT,n=o[b]
if(n==null)return A.de(a,b,!1)
else if(typeof n=="number"){t=n
s=A.b_(a,5,"#")
r=A.cJ(t)
for(q=0;q<t;++q)r[q]=s
p=A.aZ(a,b,r)
o[b]=p
return p}else return n},
fl(a,b){return A.dY(a.tR,b)},
fk(a,b){return A.dY(a.eT,b)},
de(a,b,c){var t,s=a.eC,r=s.get(b)
if(r!=null)return r
t=A.dT(A.dR(a,null,b,c))
s.set(b,t)
return t},
cI(a,b,c){var t,s,r=b.Q
if(r==null)r=b.Q=new Map()
t=r.get(c)
if(t!=null)return t
s=A.dT(A.dR(a,b,c,!0))
r.set(c,s)
return s},
fm(a,b,c){var t,s,r,q=b.as
if(q==null)q=b.as=new Map()
t=c.at
s=q.get(t)
if(s!=null)return s
r=A.db(a,b,c.x===10?c.z:[c])
q.set(t,r)
return r},
P(a,b){b.a=A.fv
b.b=A.fw
return b},
b_(a,b,c){var t,s,r=a.eC.get(c)
if(r!=null)return r
t=new A.E(null,null)
t.x=b
t.at=c
s=A.P(a,t)
a.eC.set(c,s)
return s},
dX(a,b,c){var t,s=b.at+"*",r=a.eC.get(s)
if(r!=null)return r
t=A.fh(a,b,s,c)
a.eC.set(s,t)
return t},
fh(a,b,c,d){var t,s,r
if(d){t=b.x
if(!A.R(b))s=b===u.P||b===u.T||t===7||t===6
else s=!0
if(s)return b}r=new A.E(null,null)
r.x=6
r.y=b
r.at=c
return A.P(a,r)},
dd(a,b,c){var t,s=b.at+"?",r=a.eC.get(s)
if(r!=null)return r
t=A.fg(a,b,s,c)
a.eC.set(s,t)
return t},
fg(a,b,c,d){var t,s,r,q
if(d){t=b.x
if(!A.R(b))if(!(b===u.P||b===u.T))if(t!==7)s=t===8&&A.b5(b.y)
else s=!0
else s=!0
else s=!0
if(s)return b
else if(t===1||b===u.A)return u.P
else if(t===6){r=b.y
if(r.x===8&&A.b5(r.y))return r
else return A.dJ(a,b)}}q=new A.E(null,null)
q.x=7
q.y=b
q.at=c
return A.P(a,q)},
dW(a,b,c){var t,s=b.at+"/",r=a.eC.get(s)
if(r!=null)return r
t=A.fe(a,b,s,c)
a.eC.set(s,t)
return t},
fe(a,b,c,d){var t,s,r
if(d){t=b.x
if(!A.R(b))if(!(b===u._))s=!1
else s=!0
else s=!0
if(s||b===u.K)return b
else if(t===1)return A.aZ(a,"dz",[b])
else if(b===u.P||b===u.T)return u.O}r=new A.E(null,null)
r.x=8
r.y=b
r.at=c
return A.P(a,r)},
fi(a,b){var t,s,r=""+b+"^",q=a.eC.get(r)
if(q!=null)return q
t=new A.E(null,null)
t.x=14
t.y=b
t.at=r
s=A.P(a,t)
a.eC.set(r,s)
return s},
aY(a){var t,s,r,q=a.length
for(t="",s="",r=0;r<q;++r,s=",")t+=s+a[r].at
return t},
fd(a){var t,s,r,q,p,o=a.length
for(t="",s="",r=0;r<o;r+=3,s=","){q=a[r]
p=a[r+1]?"!":":"
t+=s+q+p+a[r+2].at}return t},
aZ(a,b,c){var t,s,r,q=b
if(c.length>0)q+="<"+A.aY(c)+">"
t=a.eC.get(q)
if(t!=null)return t
s=new A.E(null,null)
s.x=9
s.y=b
s.z=c
if(c.length>0)s.c=c[0]
s.at=q
r=A.P(a,s)
a.eC.set(q,r)
return r},
db(a,b,c){var t,s,r,q,p,o
if(b.x===10){t=b.y
s=b.z.concat(c)}else{s=c
t=b}r=t.at+(";<"+A.aY(s)+">")
q=a.eC.get(r)
if(q!=null)return q
p=new A.E(null,null)
p.x=10
p.y=t
p.z=s
p.at=r
o=A.P(a,p)
a.eC.set(r,o)
return o},
fj(a,b,c){var t,s,r="+"+(b+"("+A.aY(c)+")"),q=a.eC.get(r)
if(q!=null)return q
t=new A.E(null,null)
t.x=11
t.y=b
t.z=c
t.at=r
s=A.P(a,t)
a.eC.set(r,s)
return s},
dV(a,b,c){var t,s,r,q,p,o=b.at,n=c.a,m=n.length,l=c.b,k=l.length,j=c.c,i=j.length,h="("+A.aY(n)
if(k>0){t=m>0?",":""
h+=t+"["+A.aY(l)+"]"}if(i>0){t=m>0?",":""
h+=t+"{"+A.fd(j)+"}"}s=o+(h+")")
r=a.eC.get(s)
if(r!=null)return r
q=new A.E(null,null)
q.x=12
q.y=b
q.z=c
q.at=s
p=A.P(a,q)
a.eC.set(s,p)
return p},
dc(a,b,c,d){var t,s=b.at+("<"+A.aY(c)+">"),r=a.eC.get(s)
if(r!=null)return r
t=A.ff(a,b,c,s,d)
a.eC.set(s,t)
return t},
ff(a,b,c,d,e){var t,s,r,q,p,o,n,m
if(e){t=c.length
s=A.cJ(t)
for(r=0,q=0;q<t;++q){p=c[q]
if(p.x===1){s[q]=p;++r}}if(r>0){o=A.Y(a,b,s,0)
n=A.b3(a,c,s,0)
return A.dc(a,o,n,c!==n)}}m=new A.E(null,null)
m.x=13
m.y=b
m.z=c
m.at=d
return A.P(a,m)},
dR(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
dT(a){var t,s,r,q,p,o,n,m,l,k=a.r,j=a.s
for(t=k.length,s=0;s<t;){r=k.charCodeAt(s)
if(r>=48&&r<=57)s=A.f7(s+1,r,k,j)
else if((((r|32)>>>0)-97&65535)<26||r===95||r===36||r===124)s=A.dS(a,s,k,j,!1)
else if(r===46)s=A.dS(a,s,k,j,!0)
else{++s
switch(r){case 44:break
case 58:j.push(!1)
break
case 33:j.push(!0)
break
case 59:j.push(A.X(a.u,a.e,j.pop()))
break
case 94:j.push(A.fi(a.u,j.pop()))
break
case 35:j.push(A.b_(a.u,5,"#"))
break
case 64:j.push(A.b_(a.u,2,"@"))
break
case 126:j.push(A.b_(a.u,3,"~"))
break
case 60:j.push(a.p)
a.p=j.length
break
case 62:q=a.u
p=j.splice(a.p)
A.da(a.u,a.e,p)
a.p=j.pop()
o=j.pop()
if(typeof o=="string")j.push(A.aZ(q,o,p))
else{n=A.X(q,a.e,o)
switch(n.x){case 12:j.push(A.dc(q,n,p,a.n))
break
default:j.push(A.db(q,n,p))
break}}break
case 38:A.f8(a,j)
break
case 42:q=a.u
j.push(A.dX(q,A.X(q,a.e,j.pop()),a.n))
break
case 63:q=a.u
j.push(A.dd(q,A.X(q,a.e,j.pop()),a.n))
break
case 47:q=a.u
j.push(A.dW(q,A.X(q,a.e,j.pop()),a.n))
break
case 40:j.push(-3)
j.push(a.p)
a.p=j.length
break
case 41:A.f6(a,j)
break
case 91:j.push(a.p)
a.p=j.length
break
case 93:p=j.splice(a.p)
A.da(a.u,a.e,p)
a.p=j.pop()
j.push(p)
j.push(-1)
break
case 123:j.push(a.p)
a.p=j.length
break
case 125:p=j.splice(a.p)
A.fa(a.u,a.e,p)
a.p=j.pop()
j.push(p)
j.push(-2)
break
case 43:m=k.indexOf("(",s)
j.push(k.substring(s,m))
j.push(-4)
j.push(a.p)
a.p=j.length
s=m+1
break
default:throw"Bad character "+r}}}l=j.pop()
return A.X(a.u,a.e,l)},
f7(a,b,c,d){var t,s,r=b-48
for(t=c.length;a<t;++a){s=c.charCodeAt(a)
if(!(s>=48&&s<=57))break
r=r*10+(s-48)}d.push(r)
return a},
dS(a,b,c,d,e){var t,s,r,q,p,o,n=b+1
for(t=c.length;n<t;++n){s=c.charCodeAt(n)
if(s===46){if(e)break
e=!0}else{if(!((((s|32)>>>0)-97&65535)<26||s===95||s===36||s===124))r=s>=48&&s<=57
else r=!0
if(!r)break}}q=c.substring(b,n)
if(e){t=a.u
p=a.e
if(p.x===10)p=p.y
o=A.fo(t,p.y)[q]
if(o==null)A.M('No "'+q+'" in "'+A.eZ(p)+'"')
d.push(A.cI(t,p,o))}else d.push(q)
return n},
f6(a,b){var t,s,r,q,p,o=null,n=a.u,m=b.pop()
if(typeof m=="number")switch(m){case-1:t=b.pop()
s=o
break
case-2:s=b.pop()
t=o
break
default:b.push(m)
s=o
t=s
break}else{b.push(m)
s=o
t=s}r=A.f5(a,b)
m=b.pop()
switch(m){case-3:m=b.pop()
if(t==null)t=n.sEA
if(s==null)s=n.sEA
q=A.X(n,a.e,m)
p=new A.bJ()
p.a=r
p.b=t
p.c=s
b.push(A.dV(n,q,p))
return
case-4:b.push(A.fj(n,b.pop(),r))
return
default:throw A.b(A.bc("Unexpected state under `()`: "+A.l(m)))}},
f8(a,b){var t=b.pop()
if(0===t){b.push(A.b_(a.u,1,"0&"))
return}if(1===t){b.push(A.b_(a.u,4,"1&"))
return}throw A.b(A.bc("Unexpected extended operation "+A.l(t)))},
f5(a,b){var t=b.splice(a.p)
A.da(a.u,a.e,t)
a.p=b.pop()
return t},
X(a,b,c){if(typeof c=="string")return A.aZ(a,c,a.sEA)
else if(typeof c=="number"){b.toString
return A.f9(a,b,c)}else return c},
da(a,b,c){var t,s=c.length
for(t=0;t<s;++t)c[t]=A.X(a,b,c[t])},
fa(a,b,c){var t,s=c.length
for(t=2;t<s;t+=3)c[t]=A.X(a,b,c[t])},
f9(a,b,c){var t,s,r=b.x
if(r===10){if(c===0)return b.y
t=b.z
s=t.length
if(c<=s)return t[c-1]
c-=s
b=b.y
r=b.x}else if(c===0)return b
if(r!==9)throw A.b(A.bc("Indexed base must be an interface type"))
t=b.z
if(c<=t.length)return t[c-1]
throw A.b(A.bc("Bad index "+c+" for "+b.h(0)))},
q(a,b,c,d,e){var t,s,r,q,p,o,n,m,l,k
if(b===d)return!0
if(!A.R(d))if(!(d===u._))t=!1
else t=!0
else t=!0
if(t)return!0
s=b.x
if(s===4)return!0
if(A.R(b))return!1
if(b.x!==1)t=!1
else t=!0
if(t)return!0
r=s===14
if(r)if(A.q(a,c[b.y],c,d,e))return!0
q=d.x
t=b===u.P||b===u.T
if(t){if(q===8)return A.q(a,b,c,d.y,e)
return d===u.P||d===u.T||q===7||q===6}if(d===u.K){if(s===8)return A.q(a,b.y,c,d,e)
if(s===6)return A.q(a,b.y,c,d,e)
return s!==7}if(s===6)return A.q(a,b.y,c,d,e)
if(q===6){t=A.dJ(a,d)
return A.q(a,b,c,t,e)}if(s===8){if(!A.q(a,b.y,c,d,e))return!1
return A.q(a,A.dI(a,b),c,d,e)}if(s===7){t=A.q(a,u.P,c,d,e)
return t&&A.q(a,b.y,c,d,e)}if(q===8){if(A.q(a,b,c,d.y,e))return!0
return A.q(a,b,c,A.dI(a,d),e)}if(q===7){t=A.q(a,b,c,u.P,e)
return t||A.q(a,b,c,d.y,e)}if(r)return!1
t=s!==12
if((!t||s===13)&&d===u.Z)return!0
if(q===13){if(b===u.g)return!0
if(s!==13)return!1
p=b.z
o=d.z
n=p.length
if(n!==o.length)return!1
c=c==null?p:p.concat(c)
e=e==null?o:o.concat(e)
for(m=0;m<n;++m){l=p[m]
k=o[m]
if(!A.q(a,l,c,k,e)||!A.q(a,k,e,l,c))return!1}return A.e3(a,b.y,c,d.y,e)}if(q===12){if(b===u.g)return!0
if(t)return!1
return A.e3(a,b,c,d,e)}if(s===9){if(q!==9)return!1
return A.fy(a,b,c,d,e)}t=s===11
if(t&&d===u.L)return!0
if(t&&q===11)return A.fC(a,b,c,d,e)
return!1},
e3(a2,a3,a4,a5,a6){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1
if(!A.q(a2,a3.y,a4,a5.y,a6))return!1
t=a3.z
s=a5.z
r=t.a
q=s.a
p=r.length
o=q.length
if(p>o)return!1
n=o-p
m=t.b
l=s.b
k=m.length
j=l.length
if(p+k<o+j)return!1
for(i=0;i<p;++i){h=r[i]
if(!A.q(a2,q[i],a6,h,a4))return!1}for(i=0;i<n;++i){h=m[i]
if(!A.q(a2,q[p+i],a6,h,a4))return!1}for(i=0;i<j;++i){h=m[n+i]
if(!A.q(a2,l[i],a6,h,a4))return!1}g=t.c
f=s.c
e=g.length
d=f.length
for(c=0,b=0;b<d;b+=3){a=f[b]
for(;!0;){if(c>=e)return!1
a0=g[c]
c+=3
if(a<a0)return!1
a1=g[c-2]
if(a0<a){if(a1)return!1
continue}h=f[b+1]
if(a1&&!h)return!1
h=g[c-1]
if(!A.q(a2,f[b+2],a6,h,a4))return!1
break}}for(;c<e;){if(g[c+1])return!1
c+=3}return!0},
fy(a,b,c,d,e){var t,s,r,q,p,o,n,m=b.y,l=d.y
for(;m!==l;){t=a.tR[m]
if(t==null)return!1
if(typeof t=="string"){m=t
continue}s=t[l]
if(s==null)return!1
r=s.length
q=r>0?new Array(r):v.typeUniverse.sEA
for(p=0;p<r;++p)q[p]=A.cI(a,b,s[p])
return A.dZ(a,q,null,c,d.z,e)}o=b.z
n=d.z
return A.dZ(a,o,null,c,n,e)},
dZ(a,b,c,d,e,f){var t,s,r,q=b.length
for(t=0;t<q;++t){s=b[t]
r=e[t]
if(!A.q(a,s,d,r,f))return!1}return!0},
fC(a,b,c,d,e){var t,s=b.z,r=d.z,q=s.length
if(q!==r.length)return!1
if(b.y!==d.y)return!1
for(t=0;t<q;++t)if(!A.q(a,s[t],c,r[t],e))return!1
return!0},
b5(a){var t,s=a.x
if(!(a===u.P||a===u.T))if(!A.R(a))if(s!==7)if(!(s===6&&A.b5(a.y)))t=s===8&&A.b5(a.y)
else t=!0
else t=!0
else t=!0
else t=!0
return t},
hc(a){var t
if(!A.R(a))if(!(a===u._))t=!1
else t=!0
else t=!0
return t},
R(a){var t=a.x
return t===2||t===3||t===4||t===5||a===u.X},
dY(a,b){var t,s,r=Object.keys(b),q=r.length
for(t=0;t<q;++t){s=r[t]
a[s]=b[s]}},
cJ(a){return a>0?new Array(a):v.typeUniverse.sEA},
E:function E(a,b){var _=this
_.a=a
_.b=b
_.w=_.r=_.c=null
_.x=0
_.at=_.as=_.Q=_.z=_.y=null},
bJ:function bJ(){this.c=this.b=this.a=null},
bH:function bH(){},
aX:function aX(a){this.a=a},
f_(){var t,s,r={}
if(self.scheduleImmediate!=null)return A.fT()
if(self.MutationObserver!=null&&self.document!=null){t=self.document.createElement("div")
s=self.document.createElement("span")
r.a=null
new self.MutationObserver(A.bX(new A.cq(r),1)).observe(t,{childList:true})
return new A.cp(r,t,s)}else if(self.setImmediate!=null)return A.fU()
return A.fV()},
f0(a){self.scheduleImmediate(A.bX(new A.cr(a),0))},
f1(a){self.setImmediate(A.bX(new A.cs(a),0))},
f2(a){A.fb(0,a)},
fb(a,b){var t=new A.cG()
t.aH(a,b)
return t},
fH(){var t,s
for(t=$.am;t!=null;t=$.am){$.b2=null
s=t.b
$.am=s
if(s==null)$.b1=null
t.a.$0()}},
fN(){$.dg=!0
try{A.fH()}finally{$.b2=null
$.dg=!1
if($.am!=null)$.dp().$1(A.e6())}},
fL(a){var t=new A.bF(a),s=$.b1
if(s==null){$.am=$.b1=t
if(!$.dg)$.dp().$1(A.e6())}else $.b1=s.b=t},
fM(a){var t,s,r,q=$.am
if(q==null){A.fL(a)
$.b2=$.b1
return}t=new A.bF(a)
s=$.b2
if(s==null){t.b=q
$.am=$.b2=t}else{r=s.b
t.b=r
$.b2=s.b=t
if(r==null)$.b1=t}},
fJ(a,b){A.fM(new A.cM(a,b))},
fK(a,b,c,d,e){var t,s=$.aO
if(s===c)return d.$1(e)
$.aO=c
t=s
try{s=d.$1(e)
return s}finally{$.aO=t}},
cq:function cq(a){this.a=a},
cp:function cp(a,b,c){this.a=a
this.b=b
this.c=c},
cr:function cr(a){this.a=a},
cs:function cs(a){this.a=a},
cG:function cG(){},
cH:function cH(a,b){this.a=a
this.b=b},
bK:function bK(a,b){var _=this
_.a=0
_.b=a
_.c=null
_.$ti=b},
bF:function bF(a){this.a=a
this.b=null},
aL:function aL(){},
cl:function cl(a,b){this.a=a
this.b=b},
bv:function bv(){},
cL:function cL(){},
cM:function cM(a,b){this.a=a
this.b=b},
cA:function cA(){},
cB:function cB(a,b,c){this.a=a
this.b=b
this.c=c},
bo(a,b){return new A.az(a.p("@<0>").aK(b).p("az<1,2>"))},
ac(a){return new A.aR(a.p("aR<0>"))},
d9(){var t=Object.create(null)
t["<non-identifier-key>"]=t
delete t["<non-identifier-key>"]
return t},
eK(a,b,c){var t,s
if(A.dh(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}t=A.a([],u.s)
$.a6.push(a)
try{A.fG(a,t)}finally{$.a6.pop()}s=A.dL(b,t,", ")+c
return s.charCodeAt(0)==0?s:s},
d2(a,b,c){var t,s
if(A.dh(a))return b+"..."+c
t=new A.bw(b)
$.a6.push(a)
try{s=t
s.a=A.dL(s.a,a,", ")}finally{$.a6.pop()}t.a+=c
s=t.a
return s.charCodeAt(0)==0?s:s},
dh(a){var t,s
for(t=$.a6.length,s=0;s<t;++s)if(a===$.a6[s])return!0
return!1},
fG(a,b){var t,s,r,q,p,o,n,m=a.gt(a),l=0,k=0
while(!0){if(!(l<80||k<3))break
if(!m.l())return
t=A.l(m.gm())
b.push(t)
l+=t.length+2;++k}if(!m.l()){if(k<=5)return
s=b.pop()
r=b.pop()}else{q=m.gm();++k
if(!m.l()){if(k<=4){b.push(A.l(q))
return}s=A.l(q)
r=b.pop()
l+=s.length+2}else{p=m.gm();++k
for(;m.l();q=p,p=o){o=m.gm();++k
if(k>100){while(!0){if(!(l>75&&k>3))break
l-=b.pop().length+2;--k}b.push("...")
return}}r=A.l(q)
s=A.l(p)
l+=s.length+r.length+4}}if(k>b.length+2){l+=5
n="..."}else n=null
while(!0){if(!(l>80&&b.length>3))break
l-=b.pop().length+2
if(n==null){l+=5
n="..."}}if(n!=null)b.push(n)
b.push(r)
b.push(s)},
dB(a,b){var t,s,r=A.ac(b)
for(t=a.length,s=0;s<a.length;a.length===t||(0,A.dn)(a),++s)r.a6(0,b.a(a[s]))
return r},
dC(a){var t,s={}
if(A.dh(a))return"{...}"
t=new A.bw("")
try{$.a6.push(a)
t.a+="{"
s.a=!0
a.a7(0,new A.cc(s,t))
t.a+="}"}finally{$.a6.pop()}s=t.a
return s.charCodeAt(0)==0?s:s},
aR:function aR(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
cz:function cz(a){this.a=a
this.b=null},
aS:function aS(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
aB:function aB(){},
x:function x(){},
bp:function bp(){},
cc:function cc(a,b){this.a=a
this.b=b},
a2:function a2(){},
aJ:function aJ(){},
aV:function aV(){},
aT:function aT(){},
b0:function b0(){},
h9(a){var t=A.dH(a,null)
if(t!=null)return t
throw A.b(A.dy(a))},
eI(a){if(a instanceof A.a9)return a.h(0)
return"Instance of '"+A.ci(a)+"'"},
eJ(a,b){a=A.b(a)
a.stack=b.h(0)
throw a
throw A.b("unreachable")},
eS(a,b,c){var t=A.eR(a,c)
return t},
eR(a,b){var t,s
if(Array.isArray(a))return A.a(a.slice(0),b.p("r<0>"))
t=A.a([],b.p("r<0>"))
for(s=J.b6(a);s.l();)t.push(s.gm())
return t},
dL(a,b,c){var t=J.b6(b)
if(!t.l())return a
if(c.length===0){do a+=A.l(t.gm())
while(t.l())}else{a+=A.l(t.gm())
for(;t.l();)a=a+c+A.l(t.gm())}return a},
c4(a){if(typeof a=="number"||A.e2(a)||a==null)return J.H(a)
if(typeof a=="string")return JSON.stringify(a)
return A.eI(a)},
bc(a){return new A.bb(a)},
ez(a,b){return new A.S(!1,null,b,a)},
eW(a,b){return new A.aI(null,null,!0,a,b,"Value not in range")},
cj(a,b,c,d,e){return new A.aI(b,c,!0,a,d,"Invalid value")},
eY(a,b,c){if(0>a||a>c)throw A.b(A.cj(a,0,c,"start",null))
if(b!=null){if(a>b||b>c)throw A.b(A.cj(b,a,c,"end",null))
return b}return c},
eX(a,b){if(a<0)throw A.b(A.cj(a,0,null,b,null))
return a},
c6(a,b,c,d){return new A.bg(b,!0,a,d,"Index out of range")},
bD(a){return new A.bC(a)},
dO(a){return new A.bA(a)},
d7(a){return new A.ae(a)},
T(a){return new A.bd(a)},
f(a){return new A.cw(a)},
dy(a){return new A.c5(a)},
ed(a){var t,s=B.d.ar(a),r=A.dH(s,null)
if(r==null)r=A.eV(s)
if(r!=null)return r
t=A.dy(a)
throw A.b(t)},
cu:function cu(){},
m:function m(){},
bb:function bb(a){this.a=a},
bz:function bz(){},
bq:function bq(){},
S:function S(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
aI:function aI(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
bg:function bg(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
bC:function bC(a){this.a=a},
bA:function bA(a){this.a=a},
ae:function ae(a){this.a=a},
bd:function bd(a){this.a=a},
aK:function aK(){},
be:function be(a){this.a=a},
cw:function cw(a){this.a=a},
c5:function c5(a){this.a=a},
w:function w(){},
bh:function bh(){},
I:function I(){},
n:function n(){},
bw:function bw(a){this.a=a},
eH(a,b,c){var t,s,r=document.body
r.toString
r=new A.a5(new A.u(B.r.u(r,a,b,c)),new A.c3(),u.c.p("a5<x.E>"))
t=r.gt(r)
if(!t.l())A.M(A.eL())
s=t.gm()
if(t.l())A.M(A.eM())
return u.h.a(s)},
au(a){var t,s="element tag unavailable"
try{s=a.tagName}catch(t){}return s},
aQ(a,b,c,d){var t=A.fS(new A.cv(c),u.z),s=t!=null
if(s&&!0)if(s)J.eu(a,b,t,!1)
return new A.bI(a,b,t,!1)},
dQ(a){var t=document.createElement("a"),s=new A.cC(t,window.location)
s=new A.aj(s)
s.aF(a)
return s},
f3(a,b,c,d){return!0},
f4(a,b,c,d){var t,s=d.a,r=s.a
r.href=c
t=r.hostname
s=s.b
if(!(t==s.hostname&&r.port===s.port&&r.protocol===s.protocol))if(t==="")if(r.port===""){s=r.protocol
s=s===":"||s===""}else s=!1
else s=!1
else s=!0
return s},
dU(){var t=u.N,s=A.dB(B.v,t),r=A.a(["TEMPLATE"],u.s)
t=new A.bQ(s,A.ac(t),A.ac(t),A.ac(t),null)
t.aG(null,new A.a3(B.v,new A.cF(),u.e),r,null)
return t},
fS(a,b){var t=$.aO
if(t===B.n)return a
return t.aZ(a,b)},
e:function e(){},
b8:function b8(){},
b9:function b9(){},
a8:function a8(){},
a0:function a0(){},
K:function K(){},
c2:function c2(){},
k:function k(){},
c3:function c3(){},
c:function c(){},
aa:function aa(){},
bf:function bf(){},
ab:function ab(){},
cb:function cb(){},
B:function B(){},
u:function u(a){this.a=a},
h:function h(){},
aE:function aE(){},
bu:function bu(){},
aM:function aM(){},
bx:function bx(){},
by:function by(){},
af:function af(){},
J:function J(){},
ah:function ah(){},
aU:function aU(){},
ct:function ct(){},
bG:function bG(a){this.a=a},
d1:function d1(a){this.$ti=a},
aP:function aP(){},
ai:function ai(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.$ti=d},
bI:function bI(a,b,c,d){var _=this
_.b=a
_.c=b
_.d=c
_.e=d},
cv:function cv(a){this.a=a},
aj:function aj(a){this.a=a},
aw:function aw(){},
aF:function aF(a){this.a=a},
ce:function ce(a){this.a=a},
cd:function cd(a,b,c){this.a=a
this.b=b
this.c=c},
aW:function aW(){},
cD:function cD(){},
cE:function cE(){},
bQ:function bQ(a,b,c,d,e){var _=this
_.e=a
_.a=b
_.b=c
_.c=d
_.d=e},
cF:function cF(){},
bP:function bP(){},
av:function av(a,b){var _=this
_.a=a
_.b=b
_.c=-1
_.d=null},
cC:function cC(a,b){this.a=a
this.b=b},
bR:function bR(a){this.a=a
this.b=0},
cK:function cK(a){this.a=a},
bM:function bM(){},
bN:function bN(){},
bS:function bS(){},
bT:function bT(){},
cx:function cx(){},
ad:function ad(){},
d:function d(){},
he(){var t,s=document,r=u.S
r.a(s.getElementById("student-term")).value="{xy^2 + 4x + sin x * 3^(2+x) + sqrt(x) + |2x+1|, 2, 3}"
t=s.querySelector("#runParser")
if(t!=null){t=J.b7(t)
A.aQ(t.a,t.b,new A.cT(),!1)}r.a(s.getElementById("term-eval")).value="2^3 + 4 + sin pi"
t=s.querySelector("#runEval")
if(t!=null){t=J.b7(t)
A.aQ(t.a,t.b,new A.cU(),!1)}r.a(s.getElementById("term-opt")).value="1*3 + 4 +4x"
t=s.querySelector("#runOpt")
if(t!=null){t=J.b7(t)
A.aQ(t.a,t.b,new A.cV(),!1)}r.a(s.getElementById("term-diff")).value="4x^2 + sin(x)"
r.a(s.getElementById("term-diff-var")).value="x"
t=s.querySelector("#runDiff")
if(t!=null){t=J.b7(t)
A.aQ(t.a,t.b,new A.cW(),!1)}r.a(s.getElementById("term-compare-first")).value="2x"
r.a(s.getElementById("term-compare-second")).value="x + x"
s=s.querySelector("#runCompare")
if(s!=null){s=J.b7(s)
A.aQ(s.a,s.b,new A.cX(),!1)}},
cT:function cT(){},
cU:function cU(){},
cV:function cV(){},
cW:function cW(){},
cX:function cX(){},
aH(a,b,c){var t,s,r,q,p=a.a
if(p===B.b||p===B.a||p===B.e){t=b.a
t=t===B.b||t===B.a||t===B.e}else t=!1
if(t){if(Math.abs(a.b-b.b)>c)return!1
if(Math.abs(a.d-b.d)>c)return!1
return!0}else if(p!==b.a)return!1
switch(p){case B.j:if(a.w.length!==b.w.length)return!1
for(s=0;s<a.w.length;++s){q=0
while(!0){p=b.w
if(!(q<p.length)){r=!1
break}if(A.aH(a.w[s],p[q],1e-12)){r=!0
break}++q}if(!r)return!1}break
case B.i:if(a.e!==b.e||a.f!==b.f)return!1
for(s=0;p=a.w,s<p.length;++s)if(!A.aH(p[s],b.w[s],1e-12))return!1
break
default:throw A.b(A.f("Operand.compareEqual(..): unimplemented type "+p.b))}return!0},
D(a){var t=new A.o(B.a,A.a([],u.Y))
t.a=B.b
t.b=a
return t},
t(a){var t
if(A.bV(a)||a===B.h.a9(a))return A.D(a)
t=new A.o(B.a,A.a([],u.Y))
t.b=a
return t},
dE(a,b){var t=new A.o(B.a,A.a([],u.Y))
t.a=B.c
t.b=a
t.c=b
t.R()
return t},
dD(a,b){var t,s,r,q=u.Y,p=A.a([],q),o=new A.o(B.a,p)
o.a=B.i
o.e=a
o.f=b
t=a*b
for(s=0;s<t;++s){r=new A.o(B.a,A.a([],q))
r.a=B.b
p.push(r)}return o},
d6(a,b){var t=new A.o(B.a,A.a([],u.Y))
t.a=B.e
t.b=a
t.d=b
return t},
eT(a){var t,s,r,q,p=A.a([],u.Y),o=new A.o(B.a,p)
o.a=B.j
for(t=0;t<a.length;++t){s=a[t]
q=0
while(!0){if(!(q<p.length)){r=!1
break}if(A.aH(s,p[q],1e-12)){r=!0
break}++q}if(!r)p.push(s)}return o},
d5(a,b,c){var t,s,r,q,p,o
if(!B.f.j(A.a(["+","-"],u.s),a))throw A.b(A.f("invalid operator "+a+" for addSub(..)"))
t=new A.o(B.a,A.a([],u.Y))
s=b.a
r=s===B.b
if(r&&c.a===B.b){t.a=B.b
s=b.b
r=c.b
t.b=s+(a==="+"?r:-r)}else{r=!r
if(!r||s===B.c){q=c.a
q=q===B.b||q===B.c}else q=!1
if(q){t.a=B.c
s=b.b
r=c.c
q=c.b
p=b.c
s*=r
q*=p
if(a==="+")t.b=s+q
else t.b=s-q
t.c=p*r
t.R()}else{if(!r||s===B.a){q=c.a
q=q===B.b||q===B.a}else q=!1
if(q){s=b.b
r=c.b
t.b=s+(a==="+"?r:-r)}else{if(!r||s===B.a||s===B.e){r=c.a
r=r===B.b||r===B.a||r===B.e}else r=!1
if(r){t.a=B.e
s=b.b
r=a==="+"
q=c.b
t.b=s+(r?q:-q)
s=b.d
q=c.d
t.d=s+(r?q:-q)}else if(s===B.i&&c.a===B.i){t.a=B.i
s=b.e
if(s!==c.e||b.f!==c.f)throw A.b(A.f("matrix dimensions not matching for +"))
t.e=s
t.f=b.f
for(o=0;s=b.w,o<s.length;++o)t.w.push(A.d5(a,s[o],c.w[o]))}else throw A.b(A.f("cannot apply "+a+" on "+s.b+" and "+c.a.b))}}}return t},
dF(a){var t,s=a.E(0),r=a.a
switch(r){case B.b:case B.a:case B.c:s.b=-s.b
break
case B.e:s.b=-s.b
s.d=-s.d
break
case B.i:for(t=0;r=s.w,t<r.length;++t)r[t]=A.dF(r[t])
break
default:throw A.b(A.f("cannot apply unary - on "+r.b))}return s},
cg(a,b,c){var t,s,r,q,p,o,n,m
if(!B.f.j(A.a(["*","/"],u.s),a))throw A.b(A.f("invalid operator "+a+" for mulDiv(..)"))
t=new A.o(B.a,A.a([],u.Y))
s=b.a
r=s===B.b
if(r&&c.a===B.b){t.a=B.b
s=b.b
r=c.b
if(a==="*")t.b=s*r
else t=A.dE(s,r)}else{r=!r
if(!r||s===B.c){q=c.a
q=q===B.b||q===B.c}else q=!1
if(q){t.a=B.c
s=b.b
if(a==="*"){t.b=s*c.b
t.c=b.c*c.c}else{t.b=s*c.c
t.c=b.c*c.b}t.R()}else{if(!r||s===B.a){q=c.a
q=q===B.b||q===B.a}else q=!1
if(q){s=b.b
r=c.b
if(a==="*")t.b=s*r
else t.b=s/r}else{q=a==="*"
if(q)p=(!r||s===B.c||s===B.a||s===B.e)&&c.a===B.i
else p=!1
if(p){t.a=B.i
t.e=c.e
t.f=c.f
for(o=0;s=c.w,o<s.length;++o)t.w.push(A.cg("*",b,s[o]))}else{if(q)if(s===B.i){p=c.a
p=p===B.b||p===B.c||p===B.a||p===B.e}else p=!1
else p=!1
if(p){t.a=B.i
t.e=c.e
t.f=c.f
for(o=0;s=b.w,o<s.length;++o)t.w.push(A.cg("*",s[o],c))}else{if(!r||s===B.a||s===B.e){r=c.a
r=r===B.b||r===B.a||r===B.e}else r=!1
if(r){t.a=B.e
s=c.b
r=c.d
if(q){q=b.b
p=b.d
t.b=q*s-p*r
t.d=q*r+p*s}else{n=A.cg("*",b,A.d6(s,-r))
s=c.b
r=c.d
m=s*s+r*r
t.b=n.b/m
t.d=n.d/m}}else throw A.b(A.f("cannot apply "+a+" on "+s.b+" and "+c.a.b))}}}}}return t},
C:function C(a){this.b=a},
o:function o(a,b){var _=this
_.a=a
_.b=0
_.c=1
_.d=0
_.f=_.e=1
_.r=""
_.w=b},
ch:function ch(){},
a4:function a4(a){this.a=a
this.b=0
this.c=""},
i(a,b,c){var t=u.x
t=new A.aN(new A.o(B.a,A.a([],u.Y)),A.a([],t),A.a([],t))
t.a=a
t.c=b
t.d=c
return t},
ag(a){var t=u.x,s=A.i("#",A.a([],t),A.a([],t))
s.b=A.D(a)
return s},
d8(a){var t=u.x,s=A.i("#",A.a([],t),A.a([],t))
s.b=A.t(a)
return s},
dM(a,b){var t=u.x,s=A.i("#",A.a([],t),A.a([],t))
s.b=A.d6(a,b)
return s},
aN:function aN(a,b,c){var _=this
_.a=""
_.b=a
_.c=b
_.d=c},
hl(a){return A.M(new A.bm("Field '"+a+"' has been assigned during initialization."))},
fY(a,b){var t
for(;b!==0;a=b,b=t)t=B.l.av(a,b)
return a},
F(a,b){var t,s,r,q,p,o,n="*",m=u.x
A.i("",A.a([],m),A.a([],m))
t=a.a
switch(t){case"+":s=A.i("+",A.a([],m),A.a([],m))
for(r=0;m=a.c,r<m.length;++r){q=m[r]
s.c.push(A.F(q,b))}break
case".-":s=A.i(".-",A.a([A.F(a.c[0],b)],m),A.a([],m))
break
case"-":t=a.c
if(t.length>2)throw A.b(A.f('diff(..): non-binary "-" operator is unimplemented'))
s=A.i("-",A.a([A.F(t[0],b),A.F(a.c[1],b)],m),A.a([],m))
break
case"*":t=a.c
p=t[0]
o=t.length===2?t[1]:A.i(n,B.f.az(t,1),A.a([],m))
s=A.i("+",A.a([A.i(n,A.a([A.F(p,b),o.E(0)],m),A.a([],m)),A.i(n,A.a([p.E(0),A.F(o,b)],m),A.a([],m))],m),A.a([],m))
break
case"/":t=a.c
if(t.length>2)throw A.b(A.f('diff(..): non-binary "/" operator is unimplemented'))
s=A.i("/",A.a([A.i("-",A.a([A.i(n,A.a([A.F(t[0],b),J.a_(a.c[1])],m),A.a([],m)),A.i(n,A.a([J.a_(a.c[0]),A.F(a.c[1],b)],m),A.a([],m))],m),A.a([],m)),A.i("^",A.a([J.a_(a.c[1]),A.ag(2)],m),A.a([],m))],m),A.a([],m))
break
case"^":t=a.c
if(t[1].a!=="#")throw A.b(A.f("diff(..): u^v: operator ^ only implemented for constant v"))
s=A.i(n,A.a([A.F(t[0],b),J.a_(a.c[1]),A.i("^",A.a([J.a_(a.c[0]),A.ag(A.d5("-",a.c[1].b,A.D(1)).b)],m),A.a([],m))],m),A.a([],m))
break
case"exp":s=A.i(n,A.a([A.F(a.c[0],b),A.i("exp",A.a([J.a_(a.c[0])],m),A.a([],m))],m),A.a([],m))
break
case"sin":s=A.i(n,A.a([A.F(a.c[0],b),A.i("cos",A.a([J.a_(a.c[0])],m),A.a([],m))],m),A.a([],m))
break
case"cos":s=A.i(".-",A.a([A.i(n,A.a([A.F(a.c[0],b),A.i("cos",A.a([J.a_(a.c[0])],m),A.a([],m))],m),A.a([],m))],m),A.a([],m))
break
case"$":s=A.ag(a.b.r===b?1:0)
break
case"#":m=a.b.a
if(m===B.b||m===B.c||m===B.e||m===B.a)s=A.ag(0)
else throw A.b(A.f("diff(constant): unimplemented type "+m.b))
break
default:throw A.b(A.f('diff(..): unimplemented operator "'+t+'"'))}return s},
eg(a,b,c){var t=b-a+1,s=B.h.S(B.k.T()*t+a)
while(!0){if(!(c&&s===0))break
s=B.h.S(B.k.T()*t+a)}return s},
j(c2,c3){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2,b3,b4,b5,b6,b7="unimplemented",b8='" must be integral',b9='" must be integral or real',c0="rand dimensions must be integral",c1=c2.a
switch(c1){case"+":case"-":t=A.j(c2.c[0],c3)
for(s=1;c1=c2.c,s<c1.length;++s)t=A.d5(c2.a,t,A.j(c1[s],c3))
return t
case"*":case"/":t=A.j(c2.c[0],c3)
for(s=1;c1=c2.c,s<c1.length;++s)t=A.cg(c2.a,t,A.j(c1[s],c3))
return t
case".-":return A.dF(A.j(c2.c[0],c3))
case"^":c1=A.j(c2.c[0],c3)
r=A.j(c2.c[1],c3)
q=new A.o(B.a,A.a([],u.Y))
p=c1.a
if(p===B.b&&r.a===B.b){q.a=B.b
q.b=Math.pow(c1.b,r.b)}else if(p===B.c&&r.a===B.b){q.a=B.c
q.b=Math.pow(c1.b,r.b)
q.c=Math.pow(c1.c,r.b)
q.R()}else{if(p===B.a||p===B.e){c1=r.a
c1=c1===B.a||c1===B.e}else c1=!1
if(c1)A.M(A.f(b7))
else A.M(A.f("cannot apply ^ on "+p.b+" and "+r.a.b))}return q
case"<":case"<=":case">":case">=":o=A.j(c2.c[0],c3)
n=A.j(c2.c[1],c3)
if(!B.f.j(A.a(["<","<=",">",">="],u.s),c1))A.M(A.f("invalid operator "+c1+" for relational(..)"))
q=new A.o(B.a,A.a([],u.Y))
q.a=B.w
r=o.a
if(r===B.b||r===B.a||r===B.c){p=n.a
p=p===B.b||p===B.a||p===B.c}else p=!1
if(p){m=o.b
l=n.b
if(r===B.c)m/=o.c
if(n.a===B.c)l/=n.c
switch(c1){case"<":q.b=m<l?1:0
break
case"<=":q.b=m<=l?1:0
break
case">":q.b=m>=l?1:0
break
case">=":q.b=m>=l?1:0
break}}else A.M(A.f("cannot apply "+c1+" on "+r.b+" and "+n.a.b))
return q
case"#":return c2.b
case"sin":case"cos":case"tan":case"asin":case"acos":case"atan":case"exp":case"ln":q=A.j(c2.c[0],c3)
c1=q.a
if(c1===B.b||c1===B.a)l=q.b
else if(c1===B.c)l=q.b/q.c
else if(c1===B.m)l=c2.au(q.r)
else throw A.b(A.f("cannot apply "+c2.a+" for "+c1.b))
c1=c2.a
switch(c1){case"sin":return A.t(Math.sin(l))
case"cos":return A.t(Math.cos(l))
case"tan":return A.t(Math.tan(l))
case"asin":return A.t(Math.asin(l))
case"acos":return A.t(Math.acos(l))
case"atan":return A.t(Math.atan(l))
case"exp":return A.t(Math.exp(l))
case"ln":return A.t(Math.log(l))
default:throw A.b(A.f("unimplemented eval for "+c1))}case"len":o=A.j(c2.c[0],c3)
c1=o.a
switch(c1){case B.j:return A.D(o.w.length)
default:throw A.b(A.f('argument type "'+c1.h(0)+'" of "'+c2.a+'" is invalid'))}case"min":case"max":o=A.j(c2.c[0],c3)
c1=o.a
switch(c1){case B.j:k=c2.a==="min"?1/0:-1/0
j=A.t(k)
for(c1=o.w,r=c1.length,p=c2.a,i=p==="min",h=p==="max",g=0;g<r;++g){s=c1[g]
f=s.a
switch(f){case B.b:case B.a:case B.c:e=s.b
if(f===B.c)e/=s.c
if(h&&e>k){j=s
k=e}else if(i&&e<k){j=s
k=e}break
default:throw A.b(A.f('not allowed to calculate "'+p+'" for type '+f.h(0)))}}return j.E(0)
default:throw A.b(A.f('argument type "'+c1.h(0)+'" of "'+c2.a+'" is invalid'))}case"sqrt":o=A.j(c2.c[0],c3)
c1=o.a
switch(c1){case B.b:case B.a:return A.t(Math.sqrt(o.b))
case B.c:d=Math.sqrt(o.b)
c=Math.sqrt(o.c)
b=A.bV(d)||d===B.h.a9(d)
a=A.bV(c)||c===B.h.a9(c)
if(b&&a)return A.dE(d,c)
else return A.t(d/c)
default:throw A.b(A.f('argument type "'+c1.h(0)+'" of "'+c2.a+'" is invalid'))}case"abs":l=A.j(c2.c[0],A.bo(u.N,u.n))
c1=l.a
switch(c1){case B.b:return A.D(Math.abs(l.b))
case B.a:return A.t(Math.abs(l.b))
case B.e:c1=l.b
r=l.d
return A.t(Math.sqrt(c1*c1+r*r))
default:throw A.b(A.f("abs(..) invalid for type "+c1.b))}case"binomial":a0=A.j(c2.c[0],c3)
a1=A.j(c2.c[1],c3)
if(a0.a!==B.b||!1)throw A.b(A.f('arguments of "'+c2.a+b8))
d=a0.b
g=a1.b
for(c1=d-g,s=d,a2=1;s>c1;--s)a2*=s
for(s=1;s<=g;++s)a2/=s
return A.D(a2)
case"fac":a3=A.j(c2.c[0],c3)
if(a3.a!==B.b)throw A.b(A.f('arguments of "'+c2.a+b8))
o=a3.b
for(n=1,s=1;s<=o;++s)n*=s
return A.D(n)
case"ceil":case"floor":case"int":case"round":a3=A.j(c2.c[0],c3)
c1=a3.a
if(c1!==B.b&&c1!==B.a)throw A.b(A.f('argument of "'+c2.a+b9))
o=a3.b
switch(c2.a){case"ceil":return A.D(B.h.b_(o))
case"floor":case"int":return A.D(B.h.S(o))
case"round":return A.D(B.h.L(o))
default:throw A.b(A.f(b7))}case"complex":a3=A.j(c2.c[0],c3)
a4=A.j(c2.c[1],c3)
c1=a3.a
if(!(c1!==B.b&&c1!==B.a)){c1=a4.a
c1=c1!==B.b&&c1!==B.a}else c1=!0
if(c1)throw A.b(A.f('arguments of "'+c2.a+b9))
return A.d6(a3.b,a4.b)
case"real":case"imag":a5=A.j(c2.c[0],c3)
if(a5.a!==B.e)throw A.b(A.f('arguments of "'+c2.a+b9))
switch(c2.a){case"real":return A.t(a5.b)
case"imag":return A.t(a5.d)
default:throw A.b(A.f(b7))}case"rand":case"randZ":a6=A.j(c2.c[0],c3)
a7=A.j(c2.c[1],c3)
if(a6.a!==B.b||a7.a!==B.b)throw A.b(A.f('arguments of "'+c2.a+b8))
c1=c2.d
switch(c1.length){case 0:return A.D(A.eg(a6.b,a7.b,c2.a==="randZ"))
case 1:throw A.b(A.f("rand with 1 dims is unimplemented"))
case 2:a8=A.j(c1[0],c3)
if(a8.a!==B.b)throw A.b(A.f(c0))
a9=A.j(c2.d[1],c3)
if(a9.a!==B.b)throw A.b(A.f(c0))
q=A.dD(A.e_(a8.b),A.e_(a9.b))
d=a8.b*a9.b
for(c1=u.Y,s=0;s<d;++s){r=q.w
p=A.eg(a6.b,a7.b,c2.a==="randZ")
b0=new A.o(B.a,A.a([],c1))
b0.a=B.b
b0.b=p
r[s]=b0}return q
default:throw A.b(A.f("rand requires max two dimensions"))}case"$":c1=c3.b1(c2.b.r)
r=c2.b
if(c1){c1=c3.n(0,r.r)
return c1==null?u.n.a(c1):c1}else throw A.b(A.f('eval(..): unset variable "'+r.h(0)+'"'))
case"set":b1=A.a([],u.Y)
for(s=0;c1=c2.c,s<c1.length;++s)b1.push(A.j(c1[s],c3))
return A.eT(b1)
case"vec":c1=u.Y
b1=A.a([],c1)
for(s=0;r=c2.c,s<r.length;++s)b1.push(A.j(r[s],c3))
q=new A.o(B.a,A.a([],c1))
q.a=B.x
q.w=A.eS(b1,!0,u.n)
return q
case"matrix":c1=u.Y
a8=A.a([],c1)
for(s=0;r=c2.c,s<r.length;++s)a8.push(A.j(r[s],c3))
b2=a8.length
for(b3=-1,s=0;s<b2;++s){b4=a8[s]
if(b3===-1)b3=b4.w.length
else if(b3!==b4.w.length)throw A.b(A.f("eval(..): rows have different lengths"))}j=A.dD(b2,b3)
j.w=A.a([],c1)
for(s=0;s<a8.length;++s){b4=a8[s]
for(b5=0;c1=b4.w,b5<c1.length;++b5){b6=c1[b5]
j.w.push(b6)}}return j
default:throw A.b(A.f('eval(..): unimplemented operator "'+c1+'"'))}},
dm(a){var t,s,r,q,p,o,n,m,l=a.E(0)
for(s=0;s<l.c.length;++s)l.c[s]=A.dm(l.c[s])
r=a.a
if(r==="+"){r=u.x
q=A.a([],r)
for(p=0,s=0;s<l.c.length;++s){o=l.c[s]
if(o.a==="#"){n=o.b.a
n=n===B.b||n===B.a}else n=!1
if(n)p+=o.b.b
else q.push(o)}if(Math.abs(p)>1e-12)q.push(A.d8(p))
if(q.length===1)return q[0]
else return A.i("+",q,A.a([],r))}else if(r==="*"){r=u.x
q=A.a([],r)
for(p=1,s=0;s<l.c.length;++s){o=l.c[s]
if(o.a==="#"){n=o.b.a
n=n===B.b||n===B.a}else n=!1
if(n)p*=o.b.b
else q.push(o)}if(Math.abs(p-1)>1e-12){n=A.d8(p)
if(!!q.fixed$length)A.M(A.bD("insert"))
q.splice(0,0,n)}if(Math.abs(p)<1e-12)return A.ag(0)
if(q.length===1)return q[0]
else return A.i("*",q,A.a([],r))}else if(r==="^"&&a.c.length===2){r=a.c[1]
if(r.a==="#"&&A.aH(r.b,A.D(0),1e-12))return A.ag(1)
r=a.c[1]
if(r.a==="#"&&A.aH(r.b,A.D(1),1e-12))return a.c[0]}try{t=A.j(l,A.bo(u.N,u.n))
if(t.a===B.b||t.a===B.a||t.a===B.e){r=u.x
r=A.i("#",A.a([],r),A.a([],r))
r.b=t
return r}}catch(m){}return l},
z(a){var t,s,r,q=a.a
switch(q){case"#":case"$":t=a.b
s=t.a
q=s===B.b||s===B.a||s===B.m||s===B.p?t.h(0):"("+t.h(0)+")"
break
case".-":q="(-("+A.z(a.c[0])+"))"
break
default:if(q.length>2){if(a.d.length>0){q+="<"
for(r=0;t=a.d,r<t.length;++r){if(r>0)q+=","
q+=A.z(t[r])}q+=">"}q+="("
for(r=0;t=a.c,r<t.length;++r){if(r>0)q+=","
q+=A.z(t[r])}q+=")"}else{for(q="(",r=0;t=a.c,r<t.length;++r){if(r>0)q+=a.a
q+=A.z(t[r])}q+=")"}break}return q}},J={
dl(a,b,c,d){return{i:a,p:b,e:c,x:d}},
cO(a){var t,s,r,q,p,o=a[v.dispatchPropertyName]
if(o==null)if($.dk==null){A.h7()
o=a[v.dispatchPropertyName]}if(o!=null){t=o.p
if(!1===t)return o.i
if(!0===t)return a
s=Object.getPrototypeOf(a)
if(t===s)return o.i
if(o.e===s)throw A.b(A.dO("Return interceptor for "+A.l(t(a,o))))}r=a.constructor
if(r==null)q=null
else{p=$.cy
if(p==null)p=$.cy=v.getIsolateTag("_$dart_js")
q=r[p]}if(q!=null)return q
q=A.hd(a)
if(q!=null)return q
if(typeof a=="function")return B.H
t=Object.getPrototypeOf(a)
if(t==null)return B.y
if(t===Object.prototype)return B.y
if(typeof r=="function"){p=$.cy
if(p==null)p=$.cy=v.getIsolateTag("_$dart_js")
Object.defineProperty(r,p,{value:B.q,enumerable:false,writable:true,configurable:true})
return B.q}return B.q},
eN(a){a.fixed$length=Array
return a},
dA(a){if(a<256)switch(a){case 9:case 10:case 11:case 12:case 13:case 32:case 133:case 160:return!0
default:return!1}switch(a){case 5760:case 8192:case 8193:case 8194:case 8195:case 8196:case 8197:case 8198:case 8199:case 8200:case 8201:case 8202:case 8232:case 8233:case 8239:case 8287:case 12288:case 65279:return!0
default:return!1}},
eO(a,b){var t,s
for(t=a.length;b<t;){s=B.d.C(a,b)
if(s!==32&&s!==13&&!J.dA(s))break;++b}return b},
eP(a,b){var t,s
for(;b>0;b=t){t=b-1
s=B.d.an(a,t)
if(s!==32&&s!==13&&!J.dA(s))break}return b},
ao(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.bi.prototype
return J.c8.prototype}if(typeof a=="string")return J.V.prototype
if(a==null)return J.bj.prototype
if(typeof a=="boolean")return J.c7.prototype
if(a.constructor==Array)return J.r.prototype
if(typeof a!="object"){if(typeof a=="function")return J.N.prototype
return a}if(a instanceof A.n)return a
return J.cO(a)},
dj(a){if(typeof a=="string")return J.V.prototype
if(a==null)return a
if(a.constructor==Array)return J.r.prototype
if(typeof a!="object"){if(typeof a=="function")return J.N.prototype
return a}if(a instanceof A.n)return a
return J.cO(a)},
e9(a){if(a==null)return a
if(a.constructor==Array)return J.r.prototype
if(typeof a!="object"){if(typeof a=="function")return J.N.prototype
return a}if(a instanceof A.n)return a
return J.cO(a)},
fZ(a){if(typeof a=="number")return J.ay.prototype
if(typeof a=="string")return J.V.prototype
if(a==null)return a
if(!(a instanceof A.n))return J.W.prototype
return a},
h_(a){if(typeof a=="string")return J.V.prototype
if(a==null)return a
if(!(a instanceof A.n))return J.W.prototype
return a},
b4(a){if(a==null)return a
if(typeof a!="object"){if(typeof a=="function")return J.N.prototype
return a}if(a instanceof A.n)return a
return J.cO(a)},
h0(a){if(a==null)return a
if(!(a instanceof A.n))return J.W.prototype
return a},
G(a,b){if(typeof a=="number"&&typeof b=="number")return a+b
return J.fZ(a).M(a,b)},
cZ(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.ao(a).N(a,b)},
d_(a,b){if(typeof b==="number")if(a.constructor==Array||typeof a=="string"||A.hb(a,a[v.dispatchPropertyName]))if(b>>>0===b&&b<a.length)return a[b]
return J.dj(a).n(a,b)},
eu(a,b,c,d){return J.b4(a).aJ(a,b,c,d)},
ev(a){return J.b4(a).aL(a)},
a_(a){return J.h0(a).E(a)},
ew(a,b){return J.e9(a).A(a,b)},
ex(a){return J.b4(a).gaY(a)},
c_(a){return J.ao(a).gv(a)},
b6(a){return J.e9(a).gt(a)},
aq(a){return J.dj(a).gk(a)},
b7(a){return J.b4(a).gaq(a)},
dq(a){return J.b4(a).b6(a)},
ar(a,b){return J.b4(a).sao(a,b)},
ey(a){return J.h_(a).b9(a)},
H(a){return J.ao(a).h(a)},
ax:function ax(){},
c7:function c7(){},
bj:function bj(){},
A:function A(){},
a1:function a1(){},
br:function br(){},
W:function W(){},
N:function N(){},
r:function r(a){this.$ti=a},
c9:function c9(a){this.$ti=a},
ba:function ba(a,b){var _=this
_.a=a
_.b=b
_.c=0
_.d=null},
ay:function ay(){},
bi:function bi(){},
c8:function c8(){},
V:function V(){}},B={}
var w=[A,J,B]
var $={}
A.d3.prototype={}
J.ax.prototype={
N(a,b){return a===b},
gv(a){return A.bs(a)},
h(a){return"Instance of '"+A.ci(a)+"'"}}
J.c7.prototype={
h(a){return String(a)},
gv(a){return a?519018:218159}}
J.bj.prototype={
N(a,b){return null==b},
h(a){return"null"},
gv(a){return 0}}
J.A.prototype={}
J.a1.prototype={
gv(a){return 0},
h(a){return String(a)}}
J.br.prototype={}
J.W.prototype={}
J.N.prototype={
h(a){var t=a[$.ei()]
if(t==null)return this.aD(a)
return"JavaScript function for "+J.H(t)}}
J.r.prototype={
A(a,b){return a[b]},
az(a,b){var t=a.length
if(b>t)throw A.b(A.cj(b,0,t,"start",null))
if(b===t)return A.a([],A.bU(a))
return A.a(a.slice(b,t),A.bU(a))},
am(a,b){var t,s=a.length
for(t=0;t<s;++t){if(b.$1(a[t]))return!0
if(a.length!==s)throw A.b(A.T(a))}return!1},
j(a,b){var t
for(t=0;t<a.length;++t)if(J.cZ(a[t],b))return!0
return!1},
h(a){return A.d2(a,"[","]")},
gt(a){return new J.ba(a,a.length)},
gv(a){return A.bs(a)},
gk(a){return a.length},
n(a,b){if(!(b>=0&&b<a.length))throw A.b(A.bY(a,b))
return a[b]}}
J.c9.prototype={}
J.ba.prototype={
gm(){var t=this.d
return t==null?A.al(this).c.a(t):t},
l(){var t,s=this,r=s.a,q=r.length
if(s.b!==q)throw A.b(A.dn(r))
t=s.c
if(t>=q){s.d=null
return!1}s.d=r[t]
s.c=t+1
return!0}}
J.ay.prototype={
b_(a){var t,s
if(a>=0){if(a<=2147483647){t=a|0
return a===t?t:t+1}}else if(a>=-2147483648)return a|0
s=Math.ceil(a)
if(isFinite(s))return s
throw A.b(A.bD(""+a+".ceil()"))},
S(a){var t,s
if(a>=0){if(a<=2147483647)return a|0}else if(a>=-2147483648){t=a|0
return a===t?t:t-1}s=Math.floor(a)
if(isFinite(s))return s
throw A.b(A.bD(""+a+".floor()"))},
L(a){if(a>0){if(a!==1/0)return Math.round(a)}else if(a>-1/0)return 0-Math.round(0-a)
throw A.b(A.bD(""+a+".round()"))},
a9(a){if(a<0)return-Math.round(-a)
else return Math.round(a)},
h(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gv(a){var t,s,r,q,p=a|0
if(a===p)return p&536870911
t=Math.abs(a)
s=Math.log(t)/0.6931471805599453|0
r=Math.pow(2,s)
q=t<1?t/r:r/t
return((q*9007199254740992|0)+(q*3542243181176521|0))*599197+s*1259&536870911},
av(a,b){var t=a%b
if(t===0)return 0
if(t>0)return t
if(b<0)return t-b
else return t+b},
aW(a,b){var t
if(a>0)t=this.aV(a,b)
else{t=b>31?31:b
t=a>>t>>>0}return t},
aV(a,b){return b>31?0:a>>>b}}
J.bi.prototype={}
J.c8.prototype={}
J.V.prototype={
an(a,b){if(b<0)throw A.b(A.bY(a,b))
if(b>=a.length)A.M(A.bY(a,b))
return a.charCodeAt(b)},
C(a,b){if(b>=a.length)throw A.b(A.bY(a,b))
return a.charCodeAt(b)},
M(a,b){return a+b},
b3(a,b){var t=b.length,s=a.length
if(t>s)return!1
return b===this.aA(a,s-t)},
aw(a,b){var t=a.length,s=b.length
if(s>t)return!1
return b===a.substring(0,s)},
Y(a,b,c){return a.substring(b,A.eY(b,c,a.length))},
aA(a,b){return this.Y(a,b,null)},
b9(a){return a.toLowerCase()},
ar(a){var t,s,r,q=a.trim(),p=q.length
if(p===0)return q
if(this.C(q,0)===133){t=J.eO(q,1)
if(t===p)return""}else t=0
s=p-1
r=this.an(q,s)===133?J.eP(q,s):p
if(t===0&&r===p)return q
return q.substring(t,r)},
j(a,b){return A.hj(a,b,0)},
h(a){return a},
gv(a){var t,s,r
for(t=a.length,s=0,r=0;r<t;++r){s=s+a.charCodeAt(r)&536870911
s=s+((s&524287)<<10)&536870911
s^=s>>6}s=s+((s&67108863)<<3)&536870911
s^=s>>11
return s+((s&16383)<<15)&536870911},
gk(a){return a.length},
n(a,b){if(b>=a.length)throw A.b(A.bY(a,b))
return a[b]},
$ip:1}
A.bm.prototype={
h(a){return"LateInitializationError: "+this.a}}
A.at.prototype={}
A.aC.prototype={
gt(a){return new A.aD(this,this.gk(this))},
b5(a,b){var t,s,r,q=this,p=q.gk(q)
if(b.length!==0){if(p===0)return""
t=A.l(q.A(0,0))
if(p!==q.gk(q))throw A.b(A.T(q))
for(s=t,r=1;r<p;++r){s=s+b+A.l(q.A(0,r))
if(p!==q.gk(q))throw A.b(A.T(q))}return s.charCodeAt(0)==0?s:s}else{for(r=0,s="";r<p;++r){s+=A.l(q.A(0,r))
if(p!==q.gk(q))throw A.b(A.T(q))}return s.charCodeAt(0)==0?s:s}},
U(a,b){return this.aC(0,b)}}
A.aD.prototype={
gm(){var t=this.d
return t==null?A.al(this).c.a(t):t},
l(){var t,s=this,r=s.a,q=J.dj(r),p=q.gk(r)
if(s.b!==p)throw A.b(A.T(r))
t=s.c
if(t>=p){s.d=null
return!1}s.d=q.A(r,t);++s.c
return!0}}
A.a3.prototype={
gk(a){return J.aq(this.a)},
A(a,b){return this.b.$1(J.ew(this.a,b))}}
A.a5.prototype={
gt(a){return new A.bE(J.b6(this.a),this.b)}}
A.bE.prototype={
l(){var t,s
for(t=this.a,s=this.b;t.l();)if(s.$1(t.gm()))return!0
return!1},
gm(){return this.a.gm()}}
A.cn.prototype={
B(a){var t,s,r=this,q=new RegExp(r.a).exec(a)
if(q==null)return null
t=Object.create(null)
s=r.b
if(s!==-1)t.arguments=q[s+1]
s=r.c
if(s!==-1)t.argumentsExpr=q[s+1]
s=r.d
if(s!==-1)t.expr=q[s+1]
s=r.e
if(s!==-1)t.method=q[s+1]
s=r.f
if(s!==-1)t.receiver=q[s+1]
return t}}
A.aG.prototype={
h(a){var t=this.b
if(t==null)return"NoSuchMethodError: "+this.a
return"NoSuchMethodError: method not found: '"+t+"' on null"}}
A.bl.prototype={
h(a){var t,s=this,r="NoSuchMethodError: method not found: '",q=s.b
if(q==null)return"NoSuchMethodError: "+s.a
t=s.c
if(t==null)return r+q+"' ("+s.a+")"
return r+q+"' on '"+t+"' ("+s.a+")"}}
A.bB.prototype={
h(a){var t=this.a
return t.length===0?"Error":"Error: "+t}}
A.cf.prototype={
h(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.bO.prototype={
h(a){var t,s=this.b
if(s!=null)return s
s=this.a
t=s!==null&&typeof s==="object"?s.stack:null
return this.b=t==null?"":t}}
A.a9.prototype={
h(a){var t=this.constructor,s=t==null?null:t.name
return"Closure '"+A.eh(s==null?"unknown":s)+"'"},
gba(){return this},
$C:"$1",
$R:1,
$D:null}
A.c0.prototype={$C:"$0",$R:0}
A.c1.prototype={$C:"$2",$R:2}
A.cm.prototype={}
A.ck.prototype={
h(a){var t=this.$static_name
if(t==null)return"Closure of unknown static method"
return"Closure '"+A.eh(t)+"'"}}
A.as.prototype={
N(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.as))return!1
return this.$_target===b.$_target&&this.a===b.a},
gv(a){return(A.hh(this.a)^A.bs(this.$_target))>>>0},
h(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.ci(this.a)+"'")}}
A.bt.prototype={
h(a){return"RuntimeError: "+this.a}}
A.az.prototype={
gk(a){return this.a},
gG(){return new A.aA(this,this.$ti.p("aA<1>"))},
b1(a){var t=this.b
if(t==null)return!1
return t[a]!=null},
n(a,b){var t,s,r,q,p=null
if(typeof b=="string"){t=this.b
if(t==null)return p
s=t[b]
r=s==null?p:s.b
return r}else if(typeof b=="number"&&(b&0x3fffffff)===b){q=this.c
if(q==null)return p
s=q[b]
r=s==null?p:s.b
return r}else return this.b4(b)},
b4(a){var t,s,r=this.d
if(r==null)return null
t=r[J.c_(a)&0x3fffffff]
s=this.ap(t,a)
if(s<0)return null
return t[s].b},
W(a,b,c){var t,s,r,q,p,o,n=this
if(typeof b=="string"){t=n.b
n.ab(t==null?n.b=n.a4():t,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){s=n.c
n.ab(s==null?n.c=n.a4():s,b,c)}else{r=n.d
if(r==null)r=n.d=n.a4()
q=J.c_(b)&0x3fffffff
p=r[q]
if(p==null)r[q]=[n.a5(b,c)]
else{o=n.ap(p,b)
if(o>=0)p[o].b=c
else p.push(n.a5(b,c))}}},
a7(a,b){var t=this,s=t.e,r=t.r
for(;s!=null;){b.$2(s.a,s.b)
if(r!==t.r)throw A.b(A.T(t))
s=s.c}},
ab(a,b,c){var t=a[b]
if(t==null)a[b]=this.a5(b,c)
else t.b=c},
aP(){this.r=this.r+1&1073741823},
a5(a,b){var t,s=this,r=new A.ca(a,b)
if(s.e==null)s.e=s.f=r
else{t=s.f
t.toString
r.d=t
s.f=t.c=r}++s.a
s.aP()
return r},
ap(a,b){var t,s
if(a==null)return-1
t=a.length
for(s=0;s<t;++s)if(J.cZ(a[s].a,b))return s
return-1},
h(a){return A.dC(this)},
a4(){var t=Object.create(null)
t["<non-identifier-key>"]=t
delete t["<non-identifier-key>"]
return t}}
A.ca.prototype={}
A.aA.prototype={
gk(a){return this.a.a},
gt(a){var t=this.a,s=new A.bn(t,t.r)
s.c=t.e
return s}}
A.bn.prototype={
gm(){return this.d},
l(){var t,s=this,r=s.a
if(s.b!==r.r)throw A.b(A.T(r))
t=s.c
if(t==null){s.d=null
return!1}else{s.d=t.a
s.c=t.c
return!0}}}
A.cP.prototype={
$1(a){return this.a(a)},
$S:7}
A.cQ.prototype={
$2(a,b){return this.a(a,b)},
$S:8}
A.cR.prototype={
$1(a){return this.a(a)},
$S:9}
A.E.prototype={
p(a){return A.cI(v.typeUniverse,this,a)},
aK(a){return A.fm(v.typeUniverse,this,a)}}
A.bJ.prototype={}
A.bH.prototype={
h(a){return this.a}}
A.aX.prototype={}
A.cq.prototype={
$1(a){var t=this.a,s=t.a
t.a=null
s.$0()},
$S:10}
A.cp.prototype={
$1(a){var t,s
this.a.a=a
t=this.b
s=this.c
t.firstChild?t.removeChild(s):t.appendChild(s)},
$S:11}
A.cr.prototype={
$0(){this.a.$0()},
$S:3}
A.cs.prototype={
$0(){this.a.$0()},
$S:3}
A.cG.prototype={
aH(a,b){if(self.setTimeout!=null)self.setTimeout(A.bX(new A.cH(this,b),0),a)
else throw A.b(A.bD("`setTimeout()` not found."))}}
A.cH.prototype={
$0(){this.b.$0()},
$S:1}
A.bK.prototype={}
A.bF.prototype={}
A.aL.prototype={
gk(a){var t={},s=$.aO
t.a=0
A.aQ(this.a,this.b,new A.cl(t,this),!1)
return new A.bK(s,u.a)}}
A.cl.prototype={
$1(a){++this.a.a},
$S(){return this.b.$ti.p("~(1)")}}
A.bv.prototype={}
A.cL.prototype={}
A.cM.prototype={
$0(){var t=this.a,s=this.b
A.e7(t,"error",u.K)
A.e7(s,"stackTrace",u.l)
A.eJ(t,s)},
$S:1}
A.cA.prototype={
b7(a,b){var t,s,r
try{if(B.n===$.aO){a.$1(b)
return}A.fK(null,null,this,a,b)}catch(r){t=A.ap(r)
s=A.h2(r)
A.fJ(t,s)}},
b8(a,b){return this.b7(a,b,u.B)},
aZ(a,b){return new A.cB(this,a,b)}}
A.cB.prototype={
$1(a){return this.a.b8(this.b,a)},
$S(){return this.c.p("~(0)")}}
A.aR.prototype={
gt(a){var t=new A.aS(this,this.r)
t.c=this.e
return t},
gk(a){return this.a},
j(a,b){var t,s
if(b!=="__proto__"){t=this.b
if(t==null)return!1
return t[b]!=null}else{s=this.aM(b)
return s}},
aM(a){var t=this.d
if(t==null)return!1
return this.ae(t[this.ad(a)],a)>=0},
a6(a,b){var t,s,r=this
if(typeof b=="string"&&b!=="__proto__"){t=r.b
return r.ac(t==null?r.b=A.d9():t,b)}else if(typeof b=="number"&&(b&1073741823)===b){s=r.c
return r.ac(s==null?r.c=A.d9():s,b)}else return r.aI(b)},
aI(a){var t,s,r=this,q=r.d
if(q==null)q=r.d=A.d9()
t=r.ad(a)
s=q[t]
if(s==null)q[t]=[r.a_(a)]
else{if(r.ae(s,a)>=0)return!1
s.push(r.a_(a))}return!0},
ac(a,b){if(a[b]!=null)return!1
a[b]=this.a_(b)
return!0},
a_(a){var t=this,s=new A.cz(a)
if(t.e==null)t.e=t.f=s
else t.f=t.f.b=s;++t.a
t.r=t.r+1&1073741823
return s},
ad(a){return J.c_(a)&1073741823},
ae(a,b){var t,s
if(a==null)return-1
t=a.length
for(s=0;s<t;++s)if(J.cZ(a[s].a,b))return s
return-1}}
A.cz.prototype={}
A.aS.prototype={
gm(){var t=this.d
return t==null?A.al(this).c.a(t):t},
l(){var t=this,s=t.c,r=t.a
if(t.b!==r.r)throw A.b(A.T(r))
else if(s==null){t.d=null
return!1}else{t.d=s.a
t.c=s.b
return!0}}}
A.aB.prototype={}
A.x.prototype={
gt(a){return new A.aD(a,this.gk(a))},
A(a,b){return this.n(a,b)},
h(a){return A.d2(a,"[","]")}}
A.bp.prototype={}
A.cc.prototype={
$2(a,b){var t,s=this.a
if(!s.a)this.b.a+=", "
s.a=!1
s=this.b
t=s.a+=A.l(a)
s.a=t+": "
s.a+=A.l(b)},
$S:12}
A.a2.prototype={
a7(a,b){var t,s,r,q
for(t=J.b6(this.gG()),s=A.al(this).p("a2.V");t.l();){r=t.gm()
q=this.n(0,r)
b.$2(r,q==null?s.a(q):q)}},
gk(a){return J.aq(this.gG())},
h(a){return A.dC(this)}}
A.aJ.prototype={
q(a,b){var t
for(t=J.b6(b);t.l();)this.a6(0,t.gm())},
h(a){return A.d2(this,"{","}")}}
A.aV.prototype={}
A.aT.prototype={}
A.b0.prototype={}
A.cu.prototype={
h(a){return this.aN()}}
A.m.prototype={}
A.bb.prototype={
h(a){var t=this.a
if(t!=null)return"Assertion failed: "+A.c4(t)
return"Assertion failed"}}
A.bz.prototype={}
A.bq.prototype={
h(a){return"Throw of null."}}
A.S.prototype={
ga1(){return"Invalid argument"+(!this.a?"(s)":"")},
ga0(){return""},
h(a){var t=this,s=t.c,r=s==null?"":" ("+s+")",q=t.d,p=q==null?"":": "+q,o=t.ga1()+r+p
if(!t.a)return o
return o+t.ga0()+": "+A.c4(t.ga8())},
ga8(){return this.b}}
A.aI.prototype={
ga8(){return this.b},
ga1(){return"RangeError"},
ga0(){var t,s=this.e,r=this.f
if(s==null)t=r!=null?": Not less than or equal to "+A.l(r):""
else if(r==null)t=": Not greater than or equal to "+A.l(s)
else if(r>s)t=": Not in inclusive range "+A.l(s)+".."+A.l(r)
else t=r<s?": Valid value range is empty":": Only valid value is "+A.l(s)
return t}}
A.bg.prototype={
ga8(){return this.b},
ga1(){return"RangeError"},
ga0(){if(this.b<0)return": index must not be negative"
var t=this.f
if(t===0)return": no indices are valid"
return": index should be less than "+t},
gk(a){return this.f}}
A.bC.prototype={
h(a){return"Unsupported operation: "+this.a}}
A.bA.prototype={
h(a){return"UnimplementedError: "+this.a}}
A.ae.prototype={
h(a){return"Bad state: "+this.a}}
A.bd.prototype={
h(a){var t=this.a
if(t==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.c4(t)+"."}}
A.aK.prototype={
h(a){return"Stack Overflow"},
$im:1}
A.be.prototype={
h(a){return"Reading static variable '"+this.a+"' during its initialization"}}
A.cw.prototype={
h(a){return"Exception: "+this.a}}
A.c5.prototype={
h(a){var t=this.a,s=""!==t?"FormatException: "+t:"FormatException"
return s}}
A.w.prototype={
U(a,b){return new A.a5(this,b,A.al(this).p("a5<w.E>"))},
gk(a){var t,s=this.gt(this)
for(t=0;s.l();)++t
return t},
A(a,b){var t,s,r
A.eX(b,"index")
for(t=this.gt(this),s=0;t.l();){r=t.gm()
if(b===s)return r;++s}throw A.b(A.c6(b,s,this,"index"))},
h(a){return A.eK(this,"(",")")}}
A.bh.prototype={}
A.I.prototype={
gv(a){return A.n.prototype.gv.call(this,this)},
h(a){return"null"}}
A.n.prototype={$in:1,
N(a,b){return this===b},
gv(a){return A.bs(this)},
h(a){return"Instance of '"+A.ci(this)+"'"},
toString(){return this.h(this)}}
A.bw.prototype={
gk(a){return this.a.length},
h(a){var t=this.a
return t.charCodeAt(0)==0?t:t}}
A.e.prototype={}
A.b8.prototype={
h(a){return String(a)}}
A.b9.prototype={
h(a){return String(a)}}
A.a8.prototype={$ia8:1}
A.a0.prototype={$ia0:1}
A.K.prototype={
gk(a){return a.length}}
A.c2.prototype={
h(a){return String(a)}}
A.k.prototype={
gaY(a){return new A.bG(a)},
h(a){return a.localName},
u(a,b,c,d){var t,s,r,q
if(c==null){t=$.dx
if(t==null){t=A.a([],u.Q)
s=new A.aF(t)
t.push(A.dQ(null))
t.push(A.dU())
$.dx=s
d=s}else d=t
t=$.dw
if(t==null){d.toString
t=new A.bR(d)
$.dw=t
c=t}else{d.toString
t.a=d
c=t}}if($.U==null){t=document
s=t.implementation.createHTMLDocument("")
$.U=s
$.d0=s.createRange()
s=$.U.createElement("base")
u.y.a(s)
t=t.baseURI
t.toString
s.href=t
$.U.head.appendChild(s)}t=$.U
if(t.body==null){s=t.createElement("body")
t.body=u.t.a(s)}t=$.U
if(u.t.b(a)){t=t.body
t.toString
r=t}else{t.toString
r=t.createElement(a.tagName)
$.U.body.appendChild(r)}if("createContextualFragment" in window.Range.prototype&&!B.f.j(B.K,a.tagName)){$.d0.selectNodeContents(r)
t=$.d0
q=t.createContextualFragment(b)}else{r.innerHTML=b
q=$.U.createDocumentFragment()
for(;t=r.firstChild,t!=null;)q.appendChild(t)}if(r!==$.U.body)J.dq(r)
c.aa(q)
document.adoptNode(q)
return q},
b2(a,b,c){return this.u(a,b,c,null)},
sao(a,b){this.X(a,b)},
X(a,b){a.textContent=null
a.appendChild(this.u(a,b,null,null))},
gaq(a){return new A.ai(a,"click",!1,u.C)},
$ik:1}
A.c3.prototype={
$1(a){return u.h.b(a)},
$S:13}
A.c.prototype={$ic:1}
A.aa.prototype={
aJ(a,b,c,d){return a.addEventListener(b,A.bX(c,1),!1)}}
A.bf.prototype={
gk(a){return a.length}}
A.ab.prototype={$iab:1}
A.cb.prototype={
h(a){return String(a)}}
A.B.prototype={$iB:1}
A.u.prototype={
gO(a){var t=this.a,s=t.childNodes.length
if(s===0)throw A.b(A.d7("No elements"))
if(s>1)throw A.b(A.d7("More than one element"))
t=t.firstChild
t.toString
return t},
q(a,b){var t,s,r,q=b.a,p=this.a
if(q!==p)for(t=q.childNodes.length,s=0;s<t;++s){r=q.firstChild
r.toString
p.appendChild(r)}return},
gt(a){var t=this.a.childNodes
return new A.av(t,t.length)},
gk(a){return this.a.childNodes.length},
n(a,b){return this.a.childNodes[b]}}
A.h.prototype={
b6(a){var t=a.parentNode
if(t!=null)t.removeChild(a)},
aL(a){var t
for(;t=a.firstChild,t!=null;)a.removeChild(t)},
h(a){var t=a.nodeValue
return t==null?this.aB(a):t},
$ih:1}
A.aE.prototype={
gk(a){return a.length},
n(a,b){var t=a.length
if(b>>>0!==b||b>=t)throw A.b(A.c6(b,t,a,null))
return a[b]},
A(a,b){return a[b]},
$ibk:1}
A.bu.prototype={
gk(a){return a.length}}
A.aM.prototype={
u(a,b,c,d){var t,s
if("createContextualFragment" in window.Range.prototype)return this.Z(a,b,c,d)
t=A.eH("<table>"+b+"</table>",c,d)
s=document.createDocumentFragment()
new A.u(s).q(0,new A.u(t))
return s}}
A.bx.prototype={
u(a,b,c,d){var t,s
if("createContextualFragment" in window.Range.prototype)return this.Z(a,b,c,d)
t=document
s=t.createDocumentFragment()
t=new A.u(B.z.u(t.createElement("table"),b,c,d))
t=new A.u(t.gO(t))
new A.u(s).q(0,new A.u(t.gO(t)))
return s}}
A.by.prototype={
u(a,b,c,d){var t,s
if("createContextualFragment" in window.Range.prototype)return this.Z(a,b,c,d)
t=document
s=t.createDocumentFragment()
t=new A.u(B.z.u(t.createElement("table"),b,c,d))
new A.u(s).q(0,new A.u(t.gO(t)))
return s}}
A.af.prototype={
X(a,b){var t,s
a.textContent=null
t=a.content
t.toString
J.ev(t)
s=this.u(a,b,null,null)
a.content.appendChild(s)},
$iaf:1}
A.J.prototype={}
A.ah.prototype={$iah:1}
A.aU.prototype={
gk(a){return a.length},
n(a,b){var t=a.length
if(b>>>0!==b||b>=t)throw A.b(A.c6(b,t,a,null))
return a[b]},
A(a,b){return a[b]},
$ibk:1}
A.ct.prototype={
a7(a,b){var t,s,r,q,p,o
for(t=this.gG(),s=t.length,r=this.a,q=0;q<t.length;t.length===s||(0,A.dn)(t),++q){p=t[q]
o=r.getAttribute(p)
b.$2(p,o==null?A.Q(o):o)}},
gG(){var t,s,r,q,p,o,n=this.a.attributes
n.toString
t=A.a([],u.s)
for(s=n.length,r=u.q,q=0;q<s;++q){p=r.a(n[q])
if(p.namespaceURI==null){o=p.name
o.toString
t.push(o)}}return t}}
A.bG.prototype={
n(a,b){return this.a.getAttribute(A.Q(b))},
gk(a){return this.gG().length}}
A.d1.prototype={}
A.aP.prototype={}
A.ai.prototype={}
A.bI.prototype={}
A.cv.prototype={
$1(a){return this.a.$1(a)},
$S:14}
A.aj.prototype={
aF(a){var t
if($.bL.a===0){for(t=0;t<262;++t)$.bL.W(0,B.J[t],A.h4())
for(t=0;t<12;++t)$.bL.W(0,B.o[t],A.h5())}},
H(a){return $.et().j(0,A.au(a))},
F(a,b,c){var t=$.bL.n(0,A.au(a)+"::"+b)
if(t==null)t=$.bL.n(0,"*::"+b)
if(t==null)return!1
return t.$4(a,b,c,this)},
$iL:1}
A.aw.prototype={
gt(a){return new A.av(a,this.gk(a))}}
A.aF.prototype={
H(a){return B.f.am(this.a,new A.ce(a))},
F(a,b,c){return B.f.am(this.a,new A.cd(a,b,c))},
$iL:1}
A.ce.prototype={
$1(a){return a.H(this.a)},
$S:4}
A.cd.prototype={
$1(a){return a.F(this.a,this.b,this.c)},
$S:4}
A.aW.prototype={
aG(a,b,c,d){var t,s,r
this.a.q(0,c)
t=b.U(0,new A.cD())
s=b.U(0,new A.cE())
this.b.q(0,t)
r=this.c
r.q(0,B.L)
r.q(0,s)},
H(a){return this.a.j(0,A.au(a))},
F(a,b,c){var t,s=this,r=A.au(a),q=s.c,p=r+"::"+b
if(q.j(0,p))return s.d.aX(c)
else{t="*::"+b
if(q.j(0,t))return s.d.aX(c)
else{q=s.b
if(q.j(0,p))return!0
else if(q.j(0,t))return!0
else if(q.j(0,r+"::*"))return!0
else if(q.j(0,"*::*"))return!0}}return!1},
$iL:1}
A.cD.prototype={
$1(a){return!B.f.j(B.o,a)},
$S:5}
A.cE.prototype={
$1(a){return B.f.j(B.o,a)},
$S:5}
A.bQ.prototype={
F(a,b,c){if(this.aE(a,b,c))return!0
if(b==="template"&&c==="")return!0
if(a.getAttribute("template")==="")return this.e.j(0,b)
return!1}}
A.cF.prototype={
$1(a){return"TEMPLATE::"+a},
$S:15}
A.bP.prototype={
H(a){var t
if(u.U.b(a))return!1
t=u.u.b(a)
if(t&&A.au(a)==="foreignObject")return!1
if(t)return!0
return!1},
F(a,b,c){if(b==="is"||B.d.aw(b,"on"))return!1
return this.H(a)},
$iL:1}
A.av.prototype={
l(){var t=this,s=t.c+1,r=t.b
if(s<r){t.d=J.d_(t.a,s)
t.c=s
return!0}t.d=null
t.c=r
return!1},
gm(){var t=this.d
return t==null?A.al(this).c.a(t):t}}
A.cC.prototype={}
A.bR.prototype={
aa(a){var t,s=new A.cK(this)
do{t=this.b
s.$2(a,null)}while(t!==this.b)},
K(a,b){++this.b
if(b==null||b!==a.parentNode)J.dq(a)
else b.removeChild(a)},
aU(a,b){var t,s,r,q,p,o=!0,n=null,m=null
try{n=J.ex(a)
m=n.a.getAttribute("is")
t=function(c){if(!(c.attributes instanceof NamedNodeMap))return true
if(c.id=="lastChild"||c.name=="lastChild"||c.id=="previousSibling"||c.name=="previousSibling"||c.id=="children"||c.name=="children")return true
var l=c.childNodes
if(c.lastChild&&c.lastChild!==l[l.length-1])return true
if(c.children)if(!(c.children instanceof HTMLCollection||c.children instanceof NodeList))return true
var k=0
if(c.children)k=c.children.length
for(var j=0;j<k;j++){var i=c.children[j]
if(i.id=="attributes"||i.name=="attributes"||i.id=="lastChild"||i.name=="lastChild"||i.id=="previousSibling"||i.name=="previousSibling"||i.id=="children"||i.name=="children")return true}return false}(a)
o=t?!0:!(a.attributes instanceof NamedNodeMap)}catch(q){}s="element unprintable"
try{s=J.H(a)}catch(q){}try{r=A.au(a)
this.aT(a,b,o,s,r,n,m)}catch(q){if(A.ap(q) instanceof A.S)throw q
else{this.K(a,b)
window
p=A.l(s)
if(typeof console!="undefined")window.console.warn("Removing corrupted element "+p)}}},
aT(a,b,c,d,e,f,g){var t,s,r,q,p,o,n,m=this
if(c){m.K(a,b)
window
if(typeof console!="undefined")window.console.warn("Removing element due to corrupted attributes on <"+d+">")
return}if(!m.a.H(a)){m.K(a,b)
window
t=A.l(b)
if(typeof console!="undefined")window.console.warn("Removing disallowed element <"+e+"> from "+t)
return}if(g!=null)if(!m.a.F(a,"is",g)){m.K(a,b)
window
if(typeof console!="undefined")window.console.warn("Removing disallowed type extension <"+e+' is="'+g+'">')
return}t=f.gG()
s=A.a(t.slice(0),A.bU(t))
for(r=f.gG().length-1,t=f.a,q="Removing disallowed attribute <"+e+" ";r>=0;--r){p=s[r]
o=m.a
n=J.ey(p)
A.Q(p)
if(!o.F(a,n,t.getAttribute(p))){window
o=t.getAttribute(p)
if(typeof console!="undefined")window.console.warn(q+p+'="'+A.l(o)+'">')
t.removeAttribute(p)}}if(u.f.b(a)){t=a.content
t.toString
m.aa(t)}}}
A.cK.prototype={
$2(a,b){var t,s,r,q,p,o=this.a
switch(a.nodeType){case 1:o.aU(a,b)
break
case 8:case 11:case 3:case 4:break
default:o.K(a,b)}t=a.lastChild
for(;t!=null;){s=null
try{s=t.previousSibling
if(s!=null){r=s.nextSibling
q=t
q=r==null?q!=null:r!==q
r=q}else r=!1
if(r){r=A.d7("Corrupt HTML")
throw A.b(r)}}catch(p){r=t;++o.b
q=r.parentNode
if(a!==q){if(q!=null)q.removeChild(r)}else a.removeChild(r)
t=null
s=a.lastChild}if(t!=null)this.$2(t,a)
t=s}},
$S:16}
A.bM.prototype={}
A.bN.prototype={}
A.bS.prototype={}
A.bT.prototype={}
A.cx.prototype={
T(){return Math.random()}}
A.ad.prototype={$iad:1}
A.d.prototype={
sao(a,b){this.X(a,b)},
u(a,b,c,d){var t,s,r,q,p=A.a([],u.Q)
p.push(A.dQ(null))
p.push(A.dU())
p.push(new A.bP())
c=new A.bR(new A.aF(p))
p=document
t=p.body
t.toString
s=B.r.b2(t,'<svg version="1.1">'+b+"</svg>",c)
r=p.createDocumentFragment()
p=new A.u(s)
q=p.gO(p)
for(;p=q.firstChild,p!=null;)r.appendChild(p)
return r},
gaq(a){return new A.ai(a,"click",!1,u.C)},
$id:1}
A.cT.prototype={
$1(a){var t,s,r,q,p,o,n,m,l=document,k=u.S.a(l.querySelector("#student-term")).value,j=k==null?A.Q(k):k,i="",h=""
try{t=new A.a4(A.a([],u.s))
s=A.z(t.I(j))
i=s
r=t.a
h=""
for(q=0;q<J.aq(r);++q){p=J.d_(r,q)
if(J.aq(h)>0)h=J.G(h,", ")
h=J.G(h,B.d.M('"',p)+'"')}h=B.d.M("[",h)+"]"}catch(n){o=A.ap(n)
i=J.G(i,J.H(o))}m=l.getElementById("tokens")
if(m!=null)J.ar(m,h)
l=l.getElementById("term")
if(l!=null)J.ar(l,i)},
$S:0}
A.cU.prototype={
$1(a){var t,s,r,q=document,p=u.S.a(q.querySelector("#term-eval")).value,o=p==null?A.Q(p):p,n=new A.a4(A.a([],u.s)),m=""
try{t=n.I(o)
m="Parsed "+A.z(t)+"<br/>"
m=J.G(m,"Evaluated to "+A.j(t,A.bo(u.N,u.n)).h(0))}catch(r){s=A.ap(r)
m=J.G(m,J.H(s))}q=q.getElementById("eval-output")
if(q!=null)J.ar(q,m)},
$S:0}
A.cV.prototype={
$1(a){var t,s,r,q,p=document,o=u.S.a(p.querySelector("#term-opt")).value,n=o==null?A.Q(o):o,m=new A.a4(A.a([],u.s)),l=""
try{t=m.I(n)
l="Parsed "+A.z(t)+"<br/>"
s=A.dm(t)
l=J.G(l,"Optimized to "+A.z(s))}catch(q){r=A.ap(q)
l=J.G(l,J.H(r))}p=p.getElementById("opt-output")
if(p!=null)J.ar(p,l)},
$S:0}
A.cW.prototype={
$1(a){var t,s,r,q,p,o=document,n=u.S,m=n.a(o.querySelector("#term-diff")).value,l=m==null?A.Q(m):m,k=n.a(o.querySelector("#term-diff-var")).value,j=k==null?A.Q(k):k,i=new A.a4(A.a([],u.s)),h=""
try{t=i.I(l)
h="Parsed "+A.z(t)+"<br/>"
s=A.F(t,j)
h=J.G(h,"Differentiated to "+A.z(s)+"<br/>")
r=A.dm(s)
h=J.G(h,"Optimized to "+A.z(r))}catch(p){q=A.ap(p)
h=J.G(h,J.H(q))}o=o.getElementById("diff-output")
if(o!=null)J.ar(o,h)},
$S:0}
A.cX.prototype={
$1(a){var t,s,r,q,p,o=document,n=u.S,m=n.a(o.querySelector("#term-compare-first")).value,l=m==null?A.Q(m):m,k=n.a(o.querySelector("#term-compare-second")).value,j=k==null?A.Q(k):k,i=new A.a4(A.a([],u.s)),h=""
try{t=i.I(l)
s=i.I(j)
h="Comparing &nbsp; "+A.z(t)+"&nbsp; with &nbsp;"+A.z(s)+"<br/>"
r=t.b0(s)
n=h
h=J.G(n,"Result: "+(r?"EQUAL":"UNEQUAL"))}catch(p){q=A.ap(p)
h=J.G(h,J.H(q))}o=o.getElementById("compare-output")
if(o!=null)J.ar(o,h)},
$S:0}
A.C.prototype={
aN(){return"OperandType."+this.b}}
A.o.prototype={
E(a){var t,s,r=this,q=A.a([],u.Y),p=new A.o(B.a,q)
p.a=r.a
p.b=r.b
p.c=r.c
p.d=r.d
p.e=r.e
p.f=r.f
p.r=r.r
for(t=0;s=r.w,t<s.length;++t)q.push(s[t].E(0))
return p},
R(){var t,s,r,q,p=this
if(p.a!==B.c)return
t=p.b
s=B.h.L(t)
r=p.c
q=A.fY(s,B.h.L(r))
t/=q
p.b=t
r=p.c=r/q
if(r<0){p.b=-t
t=p.c=-r}else t=r
if(t===1)p.a=B.b},
h(a){var t,s,r,q,p=this,o=p.a
switch(o){case B.w:return p.b===0?"false":"true"
case B.b:case B.a:return B.h.h(p.b)
case B.c:return B.l.h(B.h.L(p.b))+"/"+B.l.h(B.h.L(p.c))
case B.e:o=p.d
t=p.b
if(o>=0)return B.h.h(t)+"+"+B.h.h(p.d)+"i"
else return B.h.h(t)+"-"+B.h.h(-p.d)+"i"
case B.j:o=p.w
return"{"+new A.a3(o,new A.ch(),A.bU(o).p("a3<1,p>")).b5(0,",")+"}"
case B.p:case B.m:return p.r
case B.x:for(s="[",r=0;o=p.w,r<o.length;++r){if(r>0)s+=","
s+=J.H(o[r])}return s+"]"
case B.i:for(s="[",r=0;r<p.e;++r){s=(r>0?s+",":s)+"["
for(q=0;o=p.f,q<o;++q){if(q>0)s+=","
s+=J.H(p.w[r*o+q])}s+="]"}return s+"]"
default:throw A.b(A.f("unimplemented Operand.toString() for type "+o.b))}}}
A.ch.prototype={
$1(a){return a.h(0)},
$S:17}
A.a4.prototype={
I(a){var t,s,r,q,p,o,n,m,l,k,j,i,h,g=this,f=u.s
g.a=A.a([],f)
g.b=0
for(t=a.length,s="",r=0;r<t;++r){q=a[r]
if(B.d.j(" \t\n",q)){if(s.length>0){g.a.push(s)
s=""}}else if(B.d.j("+-*/()^{},|[]<>=",q)){if(s.length>0){g.a.push(s)
s=""}g.a.push(q)}else s+=q}if(s.length>0)g.a.push(s)
g.a.push("\xa7")
p=A.a([],f)
for(o=0;t=g.a,o<t.length;++o){n=t[o]
if(g.P(n)&&!B.f.j(A.a(["abs","ceil","cos","exp","imag","int","fac","floor","max","min","len","ln","real","round","sin","sqrt","tan"],f),n)&&!B.f.j(A.a(["binomial","complex","rand","randZ"],f),n)&&!B.f.j(A.a(["pi","e"],f),n))for(t=n.length,r=0;r<t;++r)p.push(n[r])
else{t=n.length
if(t>=2){m=B.d.C(n[0],0)
m=m>=48&&m<=57&&g.a2(n[1])}else m=!1
if(m){for(l="",k="",r=0;r<t;++r){q=n[r]
if(k.length===0){m=B.d.C(q,0)
m=m>=48&&m<=57}else m=!1
if(m)l+=q
else k+=q}p.push(l)
p.push(k)}else p.push(n)}}g.a=p
p=A.a([],f)
for(r=0;t=g.a,r<t.length;++r){t=t[r]
if(t==="{"){j=A.a([],f)
o=r+1
while(!0){t=g.a
if(!(o<t.length)){i=!0
break}t=t[o]
if(t==="}"){i=!0
break}if(!B.d.j("+-*/",t)){i=!1
break}j.push(t);++o
t=g.a
if(o>=t.length){i=!1
break}t=t[o]
if(t!=="|"&&t!=="}"){i=!1
break}if(t==="}"){i=!0
break}++o}if(i){p.push(j[B.h.S(B.k.T()*j.length)])
r=o}else p.push("{")}else p.push(t)}g.a=p
g.i()
h=g.D()
if(g.c!=="\xa7")throw A.b(A.f("unexpected:end"))
return h},
D(){var t,s,r=this,q=r.ah()
if(B.f.j(A.a(["<","<=",">",">="],u.s),r.c)){t=r.c
r.i()
s=u.x
q=A.i(t,A.a([q,r.ah()],s),A.a([],s))}return q},
ah(){var t,s,r,q,p,o,n=this,m=u.x,l=A.a([],m),k=A.a([],u.s)
l.push(n.ai())
while(!0){t=n.c
if(!(t==="+"||t==="-"))break
k.push(t)
n.i()
l.push(n.ai())}t=k.length
if(t===1&&k[0]==="-")return A.i("-",l,A.a([],m))
else if(t>0){for(t=u.Y,s=0;s<k.length;++s)if(k[s]==="-"){r=s+1
q=A.a([l[r]],m)
p=A.a([],m)
o=new A.aN(new A.o(B.a,A.a([],t)),A.a([],m),A.a([],m))
o.a=".-"
o.c=q
o.d=p
l[r]=o}return A.i("+",l,A.a([],m))}else return l[0]},
ai(){var t,s=this,r=u.x,q=A.a([],r),p=A.a([],u.s)
q.push(s.aj())
while(!0){t=s.c
if(t!=="*")if(t!=="/")if(t!=="\xa7")t=s.P(t)||s.c==="("
else t=!1
else t=!0
else t=!0
if(!t)break
p.push(s.c==="/"?"/":"*")
t=s.c
if(t==="*"||t==="/")s.i()
q.push(s.aj())}if(q.length===1)return q[0]
else if(p.length===1&&p[0]==="/")return A.i("/",q,A.a([],r))
else if(B.f.j(p,"/"))throw A.b(A.f("mixed * and / are unimplemented"))
else return A.i("*",q,A.a([],r))},
aj(){var t=this,s=u.x,r=A.a([],s)
r.push(t.J())
if(t.c==="^"){t.i()
r.push(t.J())
return A.i("^",r,A.a([],s))}else return r[0]},
J(){var t,s,r,q=this
if(q.c==="-"){q.i()
t=!0}else t=!1
s=q.aQ()
if(t){r=u.x
s=A.i(".-",A.a([s],r),A.a([],r))}if(q.c==="i"){q.i()
r=u.x
s=A.i("*",A.a([s,A.dM(0,1)],r),A.a([],r))}return s},
aQ(){var t,s,r,q,p,o,n,m,l,k,j,i,h,g=this
if(g.aO(g.c)){t=g.c
g.i()
if(t==="i")t="1i"
return A.dM(0,A.ed(B.d.Y(t,0,t.length-1)))}else if(g.a3(g.c)){s=A.h9(g.c)
g.i()
return A.ag(s)}else if(g.ag(g.c)){s=A.ed(g.c)
g.i()
return A.d8(s)}else{r=g.c
q=u.s
if(B.f.j(A.a(["pi","e"],q),r)){p=g.c
g.i()
r=u.x
o=A.i("#",A.a([],r),A.a([],r))
n=new A.o(B.a,A.a([],u.Y))
n.a=B.m
if(!B.f.j(A.a(["pi","e"],q),p))A.M(A.f("Operand.createIrrational(..): unknown symbol "+p))
n.r=p
o.b=n
return o}else{if(!g.af(g.c)){r=g.c
r=B.f.j(A.a(["binomial","complex","rand","randZ"],q),r)}else r=!0
if(r){m=g.c
l=g.af(m)?1:2
r=u.x
k=A.a([],r)
j=A.a([],r)
g.i()
if(g.c==="<"){g.i()
j.push(g.J())
for(;r=g.c,r===",";){g.i()
j.push(g.J())}if(r===">")g.i()
else throw A.b(A.f('expected ">"'))}if(g.c==="("){g.i()
k.push(g.D())
for(;r=g.c,r===",";){g.i()
k.push(g.D())}if(r===")")g.i()
else throw A.b(A.f('expected ")"'))
return A.i(m,k,j)}else if(l===1&&j.length===0){k.push(g.J())
return A.i(m,k,j)}else throw A.b(A.f('expected "(" or unary function'))}else{r=g.c
if(r==="@"||g.P(r)){if(g.c==="@"){g.i()
if(!g.P(g.c))throw A.b(A.f("expected:ID"))
i=!0}else i=!1
r=i?"@":""
q=g.c
g.i()
h=u.x
o=A.i("$",A.a([],h),A.a([],h))
n=new A.o(B.a,A.a([],u.Y))
n.a=B.p
n.r=r+q
o.b=n
return o}else{r=g.c
if(r==="("){g.i()
o=g.D()
if(g.c===")")g.i()
else throw A.b(A.f('expected: ")"'))
return o}else if(r==="|"){g.i()
o=g.D()
if(g.c==="|")g.i()
else throw A.b(A.f('expected:"|"'))
r=u.x
return A.i("abs",A.a([o],r),A.a([],r))}else if(r==="[")return g.aR()
else if(r==="{")return g.aS()
else throw A.b(A.f("unexpected:"+r))}}}}},
al(a){var t,s,r,q=this
if(a)if(q.c==="[")q.i()
else throw A.b(A.f('expected "["'))
t=u.x
s=A.a([],t)
r=q.c
if(r!=="]"){s.push(q.D())
for(;r=q.c,r===",";){q.i()
s.push(q.D())}}if(r==="]")q.i()
else throw A.b(A.f('expected "]"'))
return A.i("vec",s,A.a([],t))},
ak(){return this.al(!0)},
aR(){var t,s,r,q=this
if(q.c==="[")q.i()
else throw A.b(A.f('expected "["'))
if(q.c!=="[")return q.al(!1)
t=u.x
s=A.a([],t)
r=q.c
if(r!=="]"){s.push(q.ak())
for(;r=q.c,r===",";){q.i()
s.push(q.ak())}}if(r==="]")q.i()
else throw A.b(A.f('expected "]"'))
return A.i("matrix",s,A.a([],t))},
aS(){var t,s,r,q=this
if(q.c==="{")q.i()
else throw A.b(A.f('expected "{"'))
t=u.x
s=A.a([],t)
s.push(q.D())
for(;r=q.c,r===",";){q.i()
s.push(q.D())}if(r==="}")q.i()
else throw A.b(A.f('expected "}"'))
return A.i("set",s,A.a([],t))},
af(a){return B.f.j(A.a(["abs","ceil","cos","exp","imag","int","fac","floor","max","min","len","ln","real","round","sin","sqrt","tan"],u.s),a)},
aO(a){var t
if(!B.d.b3(a,"i"))return!1
t=B.d.Y(a,0,a.length-1)
if(!this.ag(t)&&!this.a3(t))return!1
return!0},
ag(a){var t,s,r=a.split(".")
if(r.length!==2)return!1
if(!this.a3(r[0]))return!1
for(t=0;s=r[1],t<J.aq(s);++t){s=B.d.C(J.d_(s,t),0)
if(!(s>=48&&s<=57))return!1}return!0},
a3(a){var t,s,r,q
if(a==="0")return!0
for(t=a.length,s=0;s<t;++s){r=a[s]
if(s===0){q=B.d.C(r,0)
q=!(q>=49&&q<=57)}else q=!1
if(q)return!1
else{if(s>0){q=B.d.C(r,0)
q=!(q>=48&&q<=57)}else q=!1
if(q)return!1}}return!0},
a2(a){var t=B.d.C(a,0)
if(t!==95)if(!(t>=65&&t<=90))t=t>=97&&t<=122
else t=!0
else t=!0
return t},
P(a){var t,s,r,q=a.length
for(t=0;t<q;++t){s=a[t]
if(t===0&&!this.a2(s))return!1
else{if(!this.a2(s)){r=B.d.C(s,0)
r=!(r>=48&&r<=57)}else r=!1
if(r)return!1}}return!0},
i(){var t=this,s=t.b,r=t.a
if(s>=r.length){t.c="\xa7"
return}t.b=s+1
t.c=r[s]}}
A.aN.prototype={
E(a){var t,s,r=u.x,q=A.i(this.a,A.a([],r),A.a([],r))
q.b=this.b
for(t=0;r=this.c,t<r.length;++t){s=r[t]
q.c.push(s.E(0))}return q},
au(a){switch(a){case"pi":return 3.141592653589793
case"e":return 2.718281828459045
default:throw A.b(A.f("getBuildInValue(..): unimplemented symbol "+a))}},
b0(a){var t,s,r,q,p,o,n,m=u.N,l=A.ac(m)
l.q(0,this.V())
l.q(0,a.V())
t=l.a===0?1:10
for(s=u.n,r=0;r<t;++r){q=A.bo(m,s)
for(p=new A.aS(l,l.r),p.c=l.e,o=A.al(p).c;p.l();){n=p.d
if(n==null)n=o.a(n)
q.W(0,n,A.t(B.k.T()))}if(!A.aH(A.j(this,q),A.j(a,q),1e-12))return!1}return!0},
V(){var t,s,r,q=u.N,p=A.ac(q)
if(this.a==="$")p.a6(0,this.b.r)
for(t=0;s=this.c,t<s.length;++t){r=s[t]
p=A.ac(q)
p.q(0,p)
p.q(0,r.V())}return p},
h(a){return A.z(this)}};(function aliases(){var t=J.ax.prototype
t.aB=t.h
t=J.a1.prototype
t.aD=t.h
t=A.w.prototype
t.aC=t.U
t=A.k.prototype
t.Z=t.u
t=A.aW.prototype
t.aE=t.F})();(function installTearOffs(){var t=hunkHelpers._static_1,s=hunkHelpers._static_0,r=hunkHelpers.installStaticTearOff
t(A,"fT","f0",2)
t(A,"fU","f1",2)
t(A,"fV","f2",2)
s(A,"e6","fN",1)
r(A,"h4",4,null,["$4"],["f3"],6,0)
r(A,"h5",4,null,["$4"],["f4"],6,0)})();(function inheritance(){var t=hunkHelpers.mixin,s=hunkHelpers.inherit,r=hunkHelpers.inheritMany
s(A.n,null)
r(A.n,[A.d3,J.ax,J.ba,A.m,A.w,A.aD,A.bh,A.cn,A.cf,A.bO,A.a9,A.a2,A.ca,A.bn,A.E,A.bJ,A.cG,A.bK,A.bF,A.aL,A.bv,A.cL,A.b0,A.cz,A.aS,A.aT,A.x,A.aJ,A.cu,A.aK,A.cw,A.c5,A.I,A.bw,A.d1,A.aj,A.aw,A.aF,A.aW,A.bP,A.av,A.cC,A.bR,A.cx,A.o,A.a4,A.aN])
r(J.ax,[J.c7,J.bj,J.A,J.r,J.ay,J.V])
r(J.A,[J.a1,A.aa,A.c2,A.c,A.cb,A.bM,A.bS])
r(J.a1,[J.br,J.W,J.N])
s(J.c9,J.r)
r(J.ay,[J.bi,J.c8])
r(A.m,[A.bm,A.bz,A.bl,A.bB,A.bt,A.bH,A.bb,A.bq,A.S,A.bC,A.bA,A.ae,A.bd,A.be])
r(A.w,[A.at,A.a5])
r(A.at,[A.aC,A.aA])
s(A.a3,A.aC)
s(A.bE,A.bh)
s(A.aG,A.bz)
r(A.a9,[A.c0,A.c1,A.cm,A.cP,A.cR,A.cq,A.cp,A.cl,A.cB,A.c3,A.cv,A.ce,A.cd,A.cD,A.cE,A.cF,A.cT,A.cU,A.cV,A.cW,A.cX,A.ch])
r(A.cm,[A.ck,A.as])
s(A.bp,A.a2)
r(A.bp,[A.az,A.ct])
r(A.c1,[A.cQ,A.cc,A.cK])
s(A.aX,A.bH)
r(A.c0,[A.cr,A.cs,A.cH,A.cM])
s(A.cA,A.cL)
s(A.aV,A.b0)
s(A.aR,A.aV)
s(A.aB,A.aT)
r(A.S,[A.aI,A.bg])
s(A.h,A.aa)
r(A.h,[A.k,A.K,A.ah])
r(A.k,[A.e,A.d])
r(A.e,[A.b8,A.b9,A.a8,A.a0,A.bf,A.ab,A.bu,A.aM,A.bx,A.by,A.af])
s(A.J,A.c)
s(A.B,A.J)
s(A.u,A.aB)
s(A.bN,A.bM)
s(A.aE,A.bN)
s(A.bT,A.bS)
s(A.aU,A.bT)
s(A.bG,A.ct)
s(A.aP,A.aL)
s(A.ai,A.aP)
s(A.bI,A.bv)
s(A.bQ,A.aW)
s(A.ad,A.d)
s(A.C,A.cu)
t(A.aT,A.x)
t(A.b0,A.aJ)
t(A.bM,A.x)
t(A.bN,A.aw)
t(A.bS,A.x)
t(A.bT,A.aw)})()
var v={typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{ec:"int",fX:"double",hg:"num",p:"String",Z:"bool",I:"Null",eQ:"List"},mangledNames:{},types:["~(B)","~()","~(~())","I()","Z(L)","Z(p)","Z(k,p,p,aj)","@(@)","@(@,p)","@(p)","I(@)","I(~())","~(n?,n?)","Z(h)","~(c)","p(p)","~(h,h?)","p(o)"],interceptorsByTag:null,leafTags:null,arrayRti:Symbol("$ti")}
A.fl(v.typeUniverse,JSON.parse('{"br":"a1","W":"a1","N":"a1","ho":"c","hu":"c","hn":"d","hw":"d","hp":"e","hz":"e","hx":"h","ht":"h","hA":"B","hr":"J","hq":"K","hD":"K","hy":"k","c9":{"r":["1"]},"V":{"p":[]},"bm":{"m":[]},"at":{"w":["1"]},"aC":{"w":["1"]},"a3":{"aC":["2"],"w":["2"],"w.E":"2"},"a5":{"w":["1"],"w.E":"1"},"aG":{"m":[]},"bl":{"m":[]},"bB":{"m":[]},"bt":{"m":[]},"az":{"a2.V":"2"},"aA":{"w":["1"],"w.E":"1"},"bH":{"m":[]},"aX":{"m":[]},"aR":{"aJ":["1"]},"aB":{"x":["1"]},"aV":{"aJ":["1"]},"bb":{"m":[]},"bz":{"m":[]},"bq":{"m":[]},"S":{"m":[]},"aI":{"m":[]},"bg":{"m":[]},"bC":{"m":[]},"bA":{"m":[]},"ae":{"m":[]},"bd":{"m":[]},"aK":{"m":[]},"be":{"m":[]},"k":{"h":[]},"B":{"c":[]},"aj":{"L":[]},"e":{"k":[],"h":[]},"b8":{"k":[],"h":[]},"b9":{"k":[],"h":[]},"a8":{"k":[],"h":[]},"a0":{"k":[],"h":[]},"K":{"h":[]},"bf":{"k":[],"h":[]},"ab":{"k":[],"h":[]},"u":{"x":["h"],"x.E":"h"},"aE":{"x":["h"],"bk":["h"],"x.E":"h"},"bu":{"k":[],"h":[]},"aM":{"k":[],"h":[]},"bx":{"k":[],"h":[]},"by":{"k":[],"h":[]},"af":{"k":[],"h":[]},"J":{"c":[]},"ah":{"h":[]},"aU":{"x":["h"],"bk":["h"],"x.E":"h"},"bG":{"a2.V":"p"},"aP":{"aL":["1"]},"ai":{"aL":["1"]},"aF":{"L":[]},"aW":{"L":[]},"bQ":{"L":[]},"bP":{"L":[]},"ad":{"d":[],"k":[],"h":[]},"d":{"k":[],"h":[]}}'))
A.fk(v.typeUniverse,JSON.parse('{"ba":1,"at":1,"aD":1,"bE":1,"bn":1,"bv":1,"aS":1,"aB":1,"bp":2,"a2":2,"aV":1,"aT":1,"b0":1,"bh":1,"aP":1,"bI":1,"aw":1,"av":1}'))
var u=(function rtii(){var t=A.e8
return{y:t("a8"),t:t("a0"),h:t("k"),R:t("m"),z:t("c"),Z:t("hv"),S:t("ab"),Q:t("r<L>"),Y:t("r<o>"),s:t("r<p>"),x:t("r<aN>"),b:t("r<@>"),T:t("bj"),g:t("N"),p:t("bk<@>"),e:t("a3<p,p>"),P:t("I"),K:t("n"),n:t("o"),L:t("hB"),U:t("ad"),l:t("hC"),N:t("p"),u:t("d"),f:t("af"),o:t("W"),q:t("ah"),c:t("u"),C:t("ai<B>"),a:t("bK<ec>"),v:t("Z"),i:t("fX"),B:t("@"),r:t("ec"),A:t("0&*"),_:t("n*"),O:t("dz<I>?"),X:t("n?"),H:t("hg")}})();(function constants(){var t=hunkHelpers.makeConstList
B.r=A.a0.prototype
B.G=J.ax.prototype
B.f=J.r.prototype
B.l=J.bi.prototype
B.h=J.ay.prototype
B.d=J.V.prototype
B.H=J.N.prototype
B.I=J.A.prototype
B.y=J.br.prototype
B.z=A.aM.prototype
B.q=J.W.prototype
B.t=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
B.A=function() {
  var toStringFunction = Object.prototype.toString;
  function getTag(o) {
    var s = toStringFunction.call(o);
    return s.substring(8, s.length - 1);
  }
  function getUnknownTag(object, tag) {
    if (/^HTML[A-Z].*Element$/.test(tag)) {
      var name = toStringFunction.call(object);
      if (name == "[object Object]") return null;
      return "HTMLElement";
    }
  }
  function getUnknownTagGenericBrowser(object, tag) {
    if (self.HTMLElement && object instanceof HTMLElement) return "HTMLElement";
    return getUnknownTag(object, tag);
  }
  function prototypeForTag(tag) {
    if (typeof window == "undefined") return null;
    if (typeof window[tag] == "undefined") return null;
    var constructor = window[tag];
    if (typeof constructor != "function") return null;
    return constructor.prototype;
  }
  function discriminator(tag) { return null; }
  var isBrowser = typeof navigator == "object";
  return {
    getTag: getTag,
    getUnknownTag: isBrowser ? getUnknownTagGenericBrowser : getUnknownTag,
    prototypeForTag: prototypeForTag,
    discriminator: discriminator };
}
B.F=function(getTagFallback) {
  return function(hooks) {
    if (typeof navigator != "object") return hooks;
    var ua = navigator.userAgent;
    if (ua.indexOf("DumpRenderTree") >= 0) return hooks;
    if (ua.indexOf("Chrome") >= 0) {
      function confirm(p) {
        return typeof window == "object" && window[p] && window[p].name == p;
      }
      if (confirm("Window") && confirm("HTMLElement")) return hooks;
    }
    hooks.getTag = getTagFallback;
  };
}
B.B=function(hooks) {
  if (typeof dartExperimentalFixupGetTag != "function") return hooks;
  hooks.getTag = dartExperimentalFixupGetTag(hooks.getTag);
}
B.C=function(hooks) {
  var getTag = hooks.getTag;
  var prototypeForTag = hooks.prototypeForTag;
  function getTagFixed(o) {
    var tag = getTag(o);
    if (tag == "Document") {
      if (!!o.xmlVersion) return "!Document";
      return "!HTMLDocument";
    }
    return tag;
  }
  function prototypeForTagFixed(tag) {
    if (tag == "Document") return null;
    return prototypeForTag(tag);
  }
  hooks.getTag = getTagFixed;
  hooks.prototypeForTag = prototypeForTagFixed;
}
B.E=function(hooks) {
  var userAgent = typeof navigator == "object" ? navigator.userAgent : "";
  if (userAgent.indexOf("Firefox") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "GeoGeolocation": "Geolocation",
    "Location": "!Location",
    "WorkerMessageEvent": "MessageEvent",
    "XMLDocument": "!Document"};
  function getTagFirefox(o) {
    var tag = getTag(o);
    return quickMap[tag] || tag;
  }
  hooks.getTag = getTagFirefox;
}
B.D=function(hooks) {
  var userAgent = typeof navigator == "object" ? navigator.userAgent : "";
  if (userAgent.indexOf("Trident/") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "HTMLDDElement": "HTMLElement",
    "HTMLDTElement": "HTMLElement",
    "HTMLPhraseElement": "HTMLElement",
    "Position": "Geoposition"
  };
  function getTagIE(o) {
    var tag = getTag(o);
    var newTag = quickMap[tag];
    if (newTag) return newTag;
    if (tag == "Object") {
      if (window.DataView && (o instanceof window.DataView)) return "DataView";
    }
    return tag;
  }
  function prototypeForTagIE(tag) {
    var constructor = window[tag];
    if (constructor == null) return null;
    return constructor.prototype;
  }
  hooks.getTag = getTagIE;
  hooks.prototypeForTag = prototypeForTagIE;
}
B.u=function(hooks) { return hooks; }

B.k=new A.cx()
B.n=new A.cA()
B.J=A.a(t(["*::class","*::dir","*::draggable","*::hidden","*::id","*::inert","*::itemprop","*::itemref","*::itemscope","*::lang","*::spellcheck","*::title","*::translate","A::accesskey","A::coords","A::hreflang","A::name","A::shape","A::tabindex","A::target","A::type","AREA::accesskey","AREA::alt","AREA::coords","AREA::nohref","AREA::shape","AREA::tabindex","AREA::target","AUDIO::controls","AUDIO::loop","AUDIO::mediagroup","AUDIO::muted","AUDIO::preload","BDO::dir","BODY::alink","BODY::bgcolor","BODY::link","BODY::text","BODY::vlink","BR::clear","BUTTON::accesskey","BUTTON::disabled","BUTTON::name","BUTTON::tabindex","BUTTON::type","BUTTON::value","CANVAS::height","CANVAS::width","CAPTION::align","COL::align","COL::char","COL::charoff","COL::span","COL::valign","COL::width","COLGROUP::align","COLGROUP::char","COLGROUP::charoff","COLGROUP::span","COLGROUP::valign","COLGROUP::width","COMMAND::checked","COMMAND::command","COMMAND::disabled","COMMAND::label","COMMAND::radiogroup","COMMAND::type","DATA::value","DEL::datetime","DETAILS::open","DIR::compact","DIV::align","DL::compact","FIELDSET::disabled","FONT::color","FONT::face","FONT::size","FORM::accept","FORM::autocomplete","FORM::enctype","FORM::method","FORM::name","FORM::novalidate","FORM::target","FRAME::name","H1::align","H2::align","H3::align","H4::align","H5::align","H6::align","HR::align","HR::noshade","HR::size","HR::width","HTML::version","IFRAME::align","IFRAME::frameborder","IFRAME::height","IFRAME::marginheight","IFRAME::marginwidth","IFRAME::width","IMG::align","IMG::alt","IMG::border","IMG::height","IMG::hspace","IMG::ismap","IMG::name","IMG::usemap","IMG::vspace","IMG::width","INPUT::accept","INPUT::accesskey","INPUT::align","INPUT::alt","INPUT::autocomplete","INPUT::autofocus","INPUT::checked","INPUT::disabled","INPUT::inputmode","INPUT::ismap","INPUT::list","INPUT::max","INPUT::maxlength","INPUT::min","INPUT::multiple","INPUT::name","INPUT::placeholder","INPUT::readonly","INPUT::required","INPUT::size","INPUT::step","INPUT::tabindex","INPUT::type","INPUT::usemap","INPUT::value","INS::datetime","KEYGEN::disabled","KEYGEN::keytype","KEYGEN::name","LABEL::accesskey","LABEL::for","LEGEND::accesskey","LEGEND::align","LI::type","LI::value","LINK::sizes","MAP::name","MENU::compact","MENU::label","MENU::type","METER::high","METER::low","METER::max","METER::min","METER::value","OBJECT::typemustmatch","OL::compact","OL::reversed","OL::start","OL::type","OPTGROUP::disabled","OPTGROUP::label","OPTION::disabled","OPTION::label","OPTION::selected","OPTION::value","OUTPUT::for","OUTPUT::name","P::align","PRE::width","PROGRESS::max","PROGRESS::min","PROGRESS::value","SELECT::autocomplete","SELECT::disabled","SELECT::multiple","SELECT::name","SELECT::required","SELECT::size","SELECT::tabindex","SOURCE::type","TABLE::align","TABLE::bgcolor","TABLE::border","TABLE::cellpadding","TABLE::cellspacing","TABLE::frame","TABLE::rules","TABLE::summary","TABLE::width","TBODY::align","TBODY::char","TBODY::charoff","TBODY::valign","TD::abbr","TD::align","TD::axis","TD::bgcolor","TD::char","TD::charoff","TD::colspan","TD::headers","TD::height","TD::nowrap","TD::rowspan","TD::scope","TD::valign","TD::width","TEXTAREA::accesskey","TEXTAREA::autocomplete","TEXTAREA::cols","TEXTAREA::disabled","TEXTAREA::inputmode","TEXTAREA::name","TEXTAREA::placeholder","TEXTAREA::readonly","TEXTAREA::required","TEXTAREA::rows","TEXTAREA::tabindex","TEXTAREA::wrap","TFOOT::align","TFOOT::char","TFOOT::charoff","TFOOT::valign","TH::abbr","TH::align","TH::axis","TH::bgcolor","TH::char","TH::charoff","TH::colspan","TH::headers","TH::height","TH::nowrap","TH::rowspan","TH::scope","TH::valign","TH::width","THEAD::align","THEAD::char","THEAD::charoff","THEAD::valign","TR::align","TR::bgcolor","TR::char","TR::charoff","TR::valign","TRACK::default","TRACK::kind","TRACK::label","TRACK::srclang","UL::compact","UL::type","VIDEO::controls","VIDEO::height","VIDEO::loop","VIDEO::mediagroup","VIDEO::muted","VIDEO::preload","VIDEO::width"]),u.s)
B.K=A.a(t(["HEAD","AREA","BASE","BASEFONT","BR","COL","COLGROUP","EMBED","FRAME","FRAMESET","HR","IMAGE","IMG","INPUT","ISINDEX","LINK","META","PARAM","SOURCE","STYLE","TITLE","WBR"]),u.s)
B.L=A.a(t([]),u.s)
B.v=A.a(t(["bind","if","ref","repeat","syntax"]),u.s)
B.o=A.a(t(["A::href","AREA::href","BLOCKQUOTE::cite","BODY::background","COMMAND::icon","DEL::cite","FORM::action","IMG::src","INPUT::src","INS::cite","Q::cite","VIDEO::poster"]),u.s)
B.w=new A.C("BOOLEAN")
B.b=new A.C("INT")
B.c=new A.C("RATIONAL")
B.a=new A.C("REAL")
B.m=new A.C("IRRATIONAL")
B.e=new A.C("COMPLEX")
B.x=new A.C("VECTOR")
B.i=new A.C("MATRIX")
B.j=new A.C("SET")
B.p=new A.C("IDENTIFIER")})();(function staticFields(){$.cy=null
$.dG=null
$.dt=null
$.ds=null
$.ea=null
$.e5=null
$.ef=null
$.cN=null
$.cS=null
$.dk=null
$.am=null
$.b1=null
$.b2=null
$.dg=!1
$.aO=B.n
$.a6=A.a([],A.e8("r<n>"))
$.U=null
$.d0=null
$.dx=null
$.dw=null
$.bL=A.bo(u.N,u.Z)})();(function lazyInitializers(){var t=hunkHelpers.lazyFinal
t($,"hs","ei",()=>A.h1("_$dart_dartClosure"))
t($,"hE","ej",()=>A.O(A.co({
toString:function(){return"$receiver$"}})))
t($,"hF","ek",()=>A.O(A.co({$method$:null,
toString:function(){return"$receiver$"}})))
t($,"hG","el",()=>A.O(A.co(null)))
t($,"hH","em",()=>A.O(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(s){return s.message}}()))
t($,"hK","ep",()=>A.O(A.co(void 0)))
t($,"hL","eq",()=>A.O(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(s){return s.message}}()))
t($,"hJ","eo",()=>A.O(A.dN(null)))
t($,"hI","en",()=>A.O(function(){try{null.$method$}catch(s){return s.message}}()))
t($,"hN","es",()=>A.O(A.dN(void 0)))
t($,"hM","er",()=>A.O(function(){try{(void 0).$method$}catch(s){return s.message}}()))
t($,"hO","dp",()=>A.f_())
t($,"hP","et",()=>A.dB(["A","ABBR","ACRONYM","ADDRESS","AREA","ARTICLE","ASIDE","AUDIO","B","BDI","BDO","BIG","BLOCKQUOTE","BR","BUTTON","CANVAS","CAPTION","CENTER","CITE","CODE","COL","COLGROUP","COMMAND","DATA","DATALIST","DD","DEL","DETAILS","DFN","DIR","DIV","DL","DT","EM","FIELDSET","FIGCAPTION","FIGURE","FONT","FOOTER","FORM","H1","H2","H3","H4","H5","H6","HEADER","HGROUP","HR","I","IFRAME","IMG","INPUT","INS","KBD","LABEL","LEGEND","LI","MAP","MARK","MENU","METER","NAV","NOBR","OL","OPTGROUP","OPTION","OUTPUT","P","PRE","PROGRESS","Q","S","SAMP","SECTION","SELECT","SMALL","SOURCE","SPAN","STRIKE","STRONG","SUB","SUMMARY","SUP","TABLE","TBODY","TD","TEXTAREA","TFOOT","TH","THEAD","TIME","TR","TRACK","TT","U","UL","VAR","VIDEO","WBR"],u.N))})();(function nativeSupport(){!function(){var t=function(a){var n={}
n[a]=1
return Object.keys(hunkHelpers.convertToFastObject(n))[0]}
v.getIsolateTag=function(a){return t("___dart_"+a+v.isolateTag)}
var s="___dart_isolate_tags_"
var r=Object[s]||(Object[s]=Object.create(null))
var q="_ZxYxX"
for(var p=0;;p++){var o=t(q+"_"+p+"_")
if(!(o in r)){r[o]=1
v.isolateTag=o
break}}v.dispatchPropertyName=v.getIsolateTag("dispatch_record")}()
hunkHelpers.setOrUpdateInterceptorsByTag({DOMError:J.A,DOMImplementation:J.A,MediaError:J.A,NavigatorUserMediaError:J.A,OverconstrainedError:J.A,PositionError:J.A,GeolocationPositionError:J.A,Range:J.A,HTMLAudioElement:A.e,HTMLBRElement:A.e,HTMLButtonElement:A.e,HTMLCanvasElement:A.e,HTMLContentElement:A.e,HTMLDListElement:A.e,HTMLDataElement:A.e,HTMLDataListElement:A.e,HTMLDetailsElement:A.e,HTMLDialogElement:A.e,HTMLDivElement:A.e,HTMLEmbedElement:A.e,HTMLFieldSetElement:A.e,HTMLHRElement:A.e,HTMLHeadElement:A.e,HTMLHeadingElement:A.e,HTMLHtmlElement:A.e,HTMLIFrameElement:A.e,HTMLImageElement:A.e,HTMLLIElement:A.e,HTMLLabelElement:A.e,HTMLLegendElement:A.e,HTMLLinkElement:A.e,HTMLMapElement:A.e,HTMLMediaElement:A.e,HTMLMenuElement:A.e,HTMLMetaElement:A.e,HTMLMeterElement:A.e,HTMLModElement:A.e,HTMLOListElement:A.e,HTMLObjectElement:A.e,HTMLOptGroupElement:A.e,HTMLOptionElement:A.e,HTMLOutputElement:A.e,HTMLParagraphElement:A.e,HTMLParamElement:A.e,HTMLPictureElement:A.e,HTMLPreElement:A.e,HTMLProgressElement:A.e,HTMLQuoteElement:A.e,HTMLScriptElement:A.e,HTMLShadowElement:A.e,HTMLSlotElement:A.e,HTMLSourceElement:A.e,HTMLSpanElement:A.e,HTMLStyleElement:A.e,HTMLTableCaptionElement:A.e,HTMLTableCellElement:A.e,HTMLTableDataCellElement:A.e,HTMLTableHeaderCellElement:A.e,HTMLTableColElement:A.e,HTMLTextAreaElement:A.e,HTMLTimeElement:A.e,HTMLTitleElement:A.e,HTMLTrackElement:A.e,HTMLUListElement:A.e,HTMLUnknownElement:A.e,HTMLVideoElement:A.e,HTMLDirectoryElement:A.e,HTMLFontElement:A.e,HTMLFrameElement:A.e,HTMLFrameSetElement:A.e,HTMLMarqueeElement:A.e,HTMLElement:A.e,HTMLAnchorElement:A.b8,HTMLAreaElement:A.b9,HTMLBaseElement:A.a8,HTMLBodyElement:A.a0,CDATASection:A.K,CharacterData:A.K,Comment:A.K,ProcessingInstruction:A.K,Text:A.K,DOMException:A.c2,MathMLElement:A.k,Element:A.k,AbortPaymentEvent:A.c,AnimationEvent:A.c,AnimationPlaybackEvent:A.c,ApplicationCacheErrorEvent:A.c,BackgroundFetchClickEvent:A.c,BackgroundFetchEvent:A.c,BackgroundFetchFailEvent:A.c,BackgroundFetchedEvent:A.c,BeforeInstallPromptEvent:A.c,BeforeUnloadEvent:A.c,BlobEvent:A.c,CanMakePaymentEvent:A.c,ClipboardEvent:A.c,CloseEvent:A.c,CustomEvent:A.c,DeviceMotionEvent:A.c,DeviceOrientationEvent:A.c,ErrorEvent:A.c,ExtendableEvent:A.c,ExtendableMessageEvent:A.c,FetchEvent:A.c,FontFaceSetLoadEvent:A.c,ForeignFetchEvent:A.c,GamepadEvent:A.c,HashChangeEvent:A.c,InstallEvent:A.c,MediaEncryptedEvent:A.c,MediaKeyMessageEvent:A.c,MediaQueryListEvent:A.c,MediaStreamEvent:A.c,MediaStreamTrackEvent:A.c,MessageEvent:A.c,MIDIConnectionEvent:A.c,MIDIMessageEvent:A.c,MutationEvent:A.c,NotificationEvent:A.c,PageTransitionEvent:A.c,PaymentRequestEvent:A.c,PaymentRequestUpdateEvent:A.c,PopStateEvent:A.c,PresentationConnectionAvailableEvent:A.c,PresentationConnectionCloseEvent:A.c,ProgressEvent:A.c,PromiseRejectionEvent:A.c,PushEvent:A.c,RTCDataChannelEvent:A.c,RTCDTMFToneChangeEvent:A.c,RTCPeerConnectionIceEvent:A.c,RTCTrackEvent:A.c,SecurityPolicyViolationEvent:A.c,SensorErrorEvent:A.c,SpeechRecognitionError:A.c,SpeechRecognitionEvent:A.c,SpeechSynthesisEvent:A.c,StorageEvent:A.c,SyncEvent:A.c,TrackEvent:A.c,TransitionEvent:A.c,WebKitTransitionEvent:A.c,VRDeviceEvent:A.c,VRDisplayEvent:A.c,VRSessionEvent:A.c,MojoInterfaceRequestEvent:A.c,ResourceProgressEvent:A.c,USBConnectionEvent:A.c,IDBVersionChangeEvent:A.c,AudioProcessingEvent:A.c,OfflineAudioCompletionEvent:A.c,WebGLContextEvent:A.c,Event:A.c,InputEvent:A.c,SubmitEvent:A.c,Window:A.aa,DOMWindow:A.aa,EventTarget:A.aa,HTMLFormElement:A.bf,HTMLInputElement:A.ab,Location:A.cb,MouseEvent:A.B,DragEvent:A.B,PointerEvent:A.B,WheelEvent:A.B,Document:A.h,DocumentFragment:A.h,HTMLDocument:A.h,ShadowRoot:A.h,XMLDocument:A.h,DocumentType:A.h,Node:A.h,NodeList:A.aE,RadioNodeList:A.aE,HTMLSelectElement:A.bu,HTMLTableElement:A.aM,HTMLTableRowElement:A.bx,HTMLTableSectionElement:A.by,HTMLTemplateElement:A.af,CompositionEvent:A.J,FocusEvent:A.J,KeyboardEvent:A.J,TextEvent:A.J,TouchEvent:A.J,UIEvent:A.J,Attr:A.ah,NamedNodeMap:A.aU,MozNamedAttrMap:A.aU,SVGScriptElement:A.ad,SVGAElement:A.d,SVGAnimateElement:A.d,SVGAnimateMotionElement:A.d,SVGAnimateTransformElement:A.d,SVGAnimationElement:A.d,SVGCircleElement:A.d,SVGClipPathElement:A.d,SVGDefsElement:A.d,SVGDescElement:A.d,SVGDiscardElement:A.d,SVGEllipseElement:A.d,SVGFEBlendElement:A.d,SVGFEColorMatrixElement:A.d,SVGFEComponentTransferElement:A.d,SVGFECompositeElement:A.d,SVGFEConvolveMatrixElement:A.d,SVGFEDiffuseLightingElement:A.d,SVGFEDisplacementMapElement:A.d,SVGFEDistantLightElement:A.d,SVGFEFloodElement:A.d,SVGFEFuncAElement:A.d,SVGFEFuncBElement:A.d,SVGFEFuncGElement:A.d,SVGFEFuncRElement:A.d,SVGFEGaussianBlurElement:A.d,SVGFEImageElement:A.d,SVGFEMergeElement:A.d,SVGFEMergeNodeElement:A.d,SVGFEMorphologyElement:A.d,SVGFEOffsetElement:A.d,SVGFEPointLightElement:A.d,SVGFESpecularLightingElement:A.d,SVGFESpotLightElement:A.d,SVGFETileElement:A.d,SVGFETurbulenceElement:A.d,SVGFilterElement:A.d,SVGForeignObjectElement:A.d,SVGGElement:A.d,SVGGeometryElement:A.d,SVGGraphicsElement:A.d,SVGImageElement:A.d,SVGLineElement:A.d,SVGLinearGradientElement:A.d,SVGMarkerElement:A.d,SVGMaskElement:A.d,SVGMetadataElement:A.d,SVGPathElement:A.d,SVGPatternElement:A.d,SVGPolygonElement:A.d,SVGPolylineElement:A.d,SVGRadialGradientElement:A.d,SVGRectElement:A.d,SVGSetElement:A.d,SVGStopElement:A.d,SVGStyleElement:A.d,SVGSVGElement:A.d,SVGSwitchElement:A.d,SVGSymbolElement:A.d,SVGTSpanElement:A.d,SVGTextContentElement:A.d,SVGTextElement:A.d,SVGTextPathElement:A.d,SVGTextPositioningElement:A.d,SVGTitleElement:A.d,SVGUseElement:A.d,SVGViewElement:A.d,SVGGradientElement:A.d,SVGComponentTransferFunctionElement:A.d,SVGFEDropShadowElement:A.d,SVGMPathElement:A.d,SVGElement:A.d})
hunkHelpers.setOrUpdateLeafTags({DOMError:true,DOMImplementation:true,MediaError:true,NavigatorUserMediaError:true,OverconstrainedError:true,PositionError:true,GeolocationPositionError:true,Range:true,HTMLAudioElement:true,HTMLBRElement:true,HTMLButtonElement:true,HTMLCanvasElement:true,HTMLContentElement:true,HTMLDListElement:true,HTMLDataElement:true,HTMLDataListElement:true,HTMLDetailsElement:true,HTMLDialogElement:true,HTMLDivElement:true,HTMLEmbedElement:true,HTMLFieldSetElement:true,HTMLHRElement:true,HTMLHeadElement:true,HTMLHeadingElement:true,HTMLHtmlElement:true,HTMLIFrameElement:true,HTMLImageElement:true,HTMLLIElement:true,HTMLLabelElement:true,HTMLLegendElement:true,HTMLLinkElement:true,HTMLMapElement:true,HTMLMediaElement:true,HTMLMenuElement:true,HTMLMetaElement:true,HTMLMeterElement:true,HTMLModElement:true,HTMLOListElement:true,HTMLObjectElement:true,HTMLOptGroupElement:true,HTMLOptionElement:true,HTMLOutputElement:true,HTMLParagraphElement:true,HTMLParamElement:true,HTMLPictureElement:true,HTMLPreElement:true,HTMLProgressElement:true,HTMLQuoteElement:true,HTMLScriptElement:true,HTMLShadowElement:true,HTMLSlotElement:true,HTMLSourceElement:true,HTMLSpanElement:true,HTMLStyleElement:true,HTMLTableCaptionElement:true,HTMLTableCellElement:true,HTMLTableDataCellElement:true,HTMLTableHeaderCellElement:true,HTMLTableColElement:true,HTMLTextAreaElement:true,HTMLTimeElement:true,HTMLTitleElement:true,HTMLTrackElement:true,HTMLUListElement:true,HTMLUnknownElement:true,HTMLVideoElement:true,HTMLDirectoryElement:true,HTMLFontElement:true,HTMLFrameElement:true,HTMLFrameSetElement:true,HTMLMarqueeElement:true,HTMLElement:false,HTMLAnchorElement:true,HTMLAreaElement:true,HTMLBaseElement:true,HTMLBodyElement:true,CDATASection:true,CharacterData:true,Comment:true,ProcessingInstruction:true,Text:true,DOMException:true,MathMLElement:true,Element:false,AbortPaymentEvent:true,AnimationEvent:true,AnimationPlaybackEvent:true,ApplicationCacheErrorEvent:true,BackgroundFetchClickEvent:true,BackgroundFetchEvent:true,BackgroundFetchFailEvent:true,BackgroundFetchedEvent:true,BeforeInstallPromptEvent:true,BeforeUnloadEvent:true,BlobEvent:true,CanMakePaymentEvent:true,ClipboardEvent:true,CloseEvent:true,CustomEvent:true,DeviceMotionEvent:true,DeviceOrientationEvent:true,ErrorEvent:true,ExtendableEvent:true,ExtendableMessageEvent:true,FetchEvent:true,FontFaceSetLoadEvent:true,ForeignFetchEvent:true,GamepadEvent:true,HashChangeEvent:true,InstallEvent:true,MediaEncryptedEvent:true,MediaKeyMessageEvent:true,MediaQueryListEvent:true,MediaStreamEvent:true,MediaStreamTrackEvent:true,MessageEvent:true,MIDIConnectionEvent:true,MIDIMessageEvent:true,MutationEvent:true,NotificationEvent:true,PageTransitionEvent:true,PaymentRequestEvent:true,PaymentRequestUpdateEvent:true,PopStateEvent:true,PresentationConnectionAvailableEvent:true,PresentationConnectionCloseEvent:true,ProgressEvent:true,PromiseRejectionEvent:true,PushEvent:true,RTCDataChannelEvent:true,RTCDTMFToneChangeEvent:true,RTCPeerConnectionIceEvent:true,RTCTrackEvent:true,SecurityPolicyViolationEvent:true,SensorErrorEvent:true,SpeechRecognitionError:true,SpeechRecognitionEvent:true,SpeechSynthesisEvent:true,StorageEvent:true,SyncEvent:true,TrackEvent:true,TransitionEvent:true,WebKitTransitionEvent:true,VRDeviceEvent:true,VRDisplayEvent:true,VRSessionEvent:true,MojoInterfaceRequestEvent:true,ResourceProgressEvent:true,USBConnectionEvent:true,IDBVersionChangeEvent:true,AudioProcessingEvent:true,OfflineAudioCompletionEvent:true,WebGLContextEvent:true,Event:false,InputEvent:false,SubmitEvent:false,Window:true,DOMWindow:true,EventTarget:false,HTMLFormElement:true,HTMLInputElement:true,Location:true,MouseEvent:true,DragEvent:true,PointerEvent:true,WheelEvent:true,Document:true,DocumentFragment:true,HTMLDocument:true,ShadowRoot:true,XMLDocument:true,DocumentType:true,Node:false,NodeList:true,RadioNodeList:true,HTMLSelectElement:true,HTMLTableElement:true,HTMLTableRowElement:true,HTMLTableSectionElement:true,HTMLTemplateElement:true,CompositionEvent:true,FocusEvent:true,KeyboardEvent:true,TextEvent:true,TouchEvent:true,UIEvent:false,Attr:true,NamedNodeMap:true,MozNamedAttrMap:true,SVGScriptElement:true,SVGAElement:true,SVGAnimateElement:true,SVGAnimateMotionElement:true,SVGAnimateTransformElement:true,SVGAnimationElement:true,SVGCircleElement:true,SVGClipPathElement:true,SVGDefsElement:true,SVGDescElement:true,SVGDiscardElement:true,SVGEllipseElement:true,SVGFEBlendElement:true,SVGFEColorMatrixElement:true,SVGFEComponentTransferElement:true,SVGFECompositeElement:true,SVGFEConvolveMatrixElement:true,SVGFEDiffuseLightingElement:true,SVGFEDisplacementMapElement:true,SVGFEDistantLightElement:true,SVGFEFloodElement:true,SVGFEFuncAElement:true,SVGFEFuncBElement:true,SVGFEFuncGElement:true,SVGFEFuncRElement:true,SVGFEGaussianBlurElement:true,SVGFEImageElement:true,SVGFEMergeElement:true,SVGFEMergeNodeElement:true,SVGFEMorphologyElement:true,SVGFEOffsetElement:true,SVGFEPointLightElement:true,SVGFESpecularLightingElement:true,SVGFESpotLightElement:true,SVGFETileElement:true,SVGFETurbulenceElement:true,SVGFilterElement:true,SVGForeignObjectElement:true,SVGGElement:true,SVGGeometryElement:true,SVGGraphicsElement:true,SVGImageElement:true,SVGLineElement:true,SVGLinearGradientElement:true,SVGMarkerElement:true,SVGMaskElement:true,SVGMetadataElement:true,SVGPathElement:true,SVGPatternElement:true,SVGPolygonElement:true,SVGPolylineElement:true,SVGRadialGradientElement:true,SVGRectElement:true,SVGSetElement:true,SVGStopElement:true,SVGStyleElement:true,SVGSVGElement:true,SVGSwitchElement:true,SVGSymbolElement:true,SVGTSpanElement:true,SVGTextContentElement:true,SVGTextElement:true,SVGTextPathElement:true,SVGTextPositioningElement:true,SVGTitleElement:true,SVGUseElement:true,SVGViewElement:true,SVGGradientElement:true,SVGComponentTransferFunctionElement:true,SVGFEDropShadowElement:true,SVGMPathElement:true,SVGElement:false})})()
convertAllToFastObject(w)
convertToFastObject($);(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!="undefined"){a(document.currentScript)
return}var t=document.scripts
function onLoad(b){for(var r=0;r<t.length;++r)t[r].removeEventListener("load",onLoad,false)
a(b.target)}for(var s=0;s<t.length;++s)t[s].addEventListener("load",onLoad,false)})(function(a){v.currentScript=a
var t=A.he
if(typeof dartMainRunner==="function")dartMainRunner(t,[])
else t([])})})()
//# sourceMappingURL=index.js.map

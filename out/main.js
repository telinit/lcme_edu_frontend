(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}

console.warn('Compiled in DEV mode. Follow the advice at https://elm-lang.org/0.19.1/optimize for better performance and smaller assets.');


var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log_UNUSED = F2(function(tag, value)
{
	return value;
});

var _Debug_log = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString_UNUSED(value)
{
	return '<internals>';
}

function _Debug_toString(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File !== 'undefined' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[36m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash_UNUSED(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.start.line === region.end.line)
	{
		return 'on line ' + region.start.line;
	}
	return 'on lines ' + region.start.line + ' through ' + region.end.line;
}



// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	/**/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**_UNUSED/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**_UNUSED/
	if (typeof x.$ === 'undefined')
	//*/
	/**/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0_UNUSED = 0;
var _Utils_Tuple0 = { $: '#0' };

function _Utils_Tuple2_UNUSED(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3_UNUSED(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr_UNUSED(c) { return c; }
function _Utils_chr(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil_UNUSED = { $: 0 };
var _List_Nil = { $: '[]' };

function _List_Cons_UNUSED(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return !isNaN(word)
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap(value) { return { $: 0, a: value }; }
function _Json_unwrap(value) { return value.a; }

function _Json_wrap_UNUSED(value) { return value; }
function _Json_unwrap_UNUSED(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**/, _Json_errorToString(result.a) /**/);
	var managers = {};
	var initPair = init(result.a);
	var model = initPair.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		var pair = A2(update, msg, model);
		stepper(model = pair.a, viewMetadata);
		_Platform_enqueueEffects(managers, pair.b, subscriptions(model));
	}

	_Platform_enqueueEffects(managers, initPair.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.p, fx.q, fx.r);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				s: bag.n,
				t: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.t)
		{
			x = temp.s(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		u: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		u: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}




// HELPERS


var _VirtualDom_divertHrefToApp;

var _VirtualDom_doc = typeof document !== 'undefined' ? document : {};


function _VirtualDom_appendChild(parent, child)
{
	parent.appendChild(child);
}

var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)
{
	// NOTE: this function needs _Platform_export available to work

	/**_UNUSED/
	var node = args['node'];
	//*/
	/**/
	var node = args && args['node'] ? args['node'] : _Debug_crash(0);
	//*/

	node.parentNode.replaceChild(
		_VirtualDom_render(virtualNode, function() {}),
		node
	);

	return {};
});



// TEXT


function _VirtualDom_text(string)
{
	return {
		$: 0,
		a: string
	};
}



// NODE


var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 1,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_node = _VirtualDom_nodeNS(undefined);



// KEYED NODE


var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 2,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(undefined);



// CUSTOM


function _VirtualDom_custom(factList, model, render, diff)
{
	return {
		$: 3,
		d: _VirtualDom_organizeFacts(factList),
		g: model,
		h: render,
		i: diff
	};
}



// MAP


var _VirtualDom_map = F2(function(tagger, node)
{
	return {
		$: 4,
		j: tagger,
		k: node,
		b: 1 + (node.b || 0)
	};
});



// LAZY


function _VirtualDom_thunk(refs, thunk)
{
	return {
		$: 5,
		l: refs,
		m: thunk,
		k: undefined
	};
}

var _VirtualDom_lazy = F2(function(func, a)
{
	return _VirtualDom_thunk([func, a], function() {
		return func(a);
	});
});

var _VirtualDom_lazy2 = F3(function(func, a, b)
{
	return _VirtualDom_thunk([func, a, b], function() {
		return A2(func, a, b);
	});
});

var _VirtualDom_lazy3 = F4(function(func, a, b, c)
{
	return _VirtualDom_thunk([func, a, b, c], function() {
		return A3(func, a, b, c);
	});
});

var _VirtualDom_lazy4 = F5(function(func, a, b, c, d)
{
	return _VirtualDom_thunk([func, a, b, c, d], function() {
		return A4(func, a, b, c, d);
	});
});

var _VirtualDom_lazy5 = F6(function(func, a, b, c, d, e)
{
	return _VirtualDom_thunk([func, a, b, c, d, e], function() {
		return A5(func, a, b, c, d, e);
	});
});

var _VirtualDom_lazy6 = F7(function(func, a, b, c, d, e, f)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f], function() {
		return A6(func, a, b, c, d, e, f);
	});
});

var _VirtualDom_lazy7 = F8(function(func, a, b, c, d, e, f, g)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function() {
		return A7(func, a, b, c, d, e, f, g);
	});
});

var _VirtualDom_lazy8 = F9(function(func, a, b, c, d, e, f, g, h)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function() {
		return A8(func, a, b, c, d, e, f, g, h);
	});
});



// FACTS


var _VirtualDom_on = F2(function(key, handler)
{
	return {
		$: 'a0',
		n: key,
		o: handler
	};
});
var _VirtualDom_style = F2(function(key, value)
{
	return {
		$: 'a1',
		n: key,
		o: value
	};
});
var _VirtualDom_property = F2(function(key, value)
{
	return {
		$: 'a2',
		n: key,
		o: value
	};
});
var _VirtualDom_attribute = F2(function(key, value)
{
	return {
		$: 'a3',
		n: key,
		o: value
	};
});
var _VirtualDom_attributeNS = F3(function(namespace, key, value)
{
	return {
		$: 'a4',
		n: key,
		o: { f: namespace, o: value }
	};
});



// XSS ATTACK VECTOR CHECKS
//
// For some reason, tabs can appear in href protocols and it still works.
// So '\tjava\tSCRIPT:alert("!!!")' and 'javascript:alert("!!!")' are the same
// in practice. That is why _VirtualDom_RE_js and _VirtualDom_RE_js_html look
// so freaky.
//
// Pulling the regular expressions out to the top level gives a slight speed
// boost in small benchmarks (4-10%) but hoisting values to reduce allocation
// can be unpredictable in large programs where JIT may have a harder time with
// functions are not fully self-contained. The benefit is more that the js and
// js_html ones are so weird that I prefer to see them near each other.


var _VirtualDom_RE_script = /^script$/i;
var _VirtualDom_RE_on_formAction = /^(on|formAction$)/i;
var _VirtualDom_RE_js = /^\s*j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:/i;
var _VirtualDom_RE_js_html = /^\s*(j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:|d\s*a\s*t\s*a\s*:\s*t\s*e\s*x\s*t\s*\/\s*h\s*t\s*m\s*l\s*(,|;))/i;


function _VirtualDom_noScript(tag)
{
	return _VirtualDom_RE_script.test(tag) ? 'p' : tag;
}

function _VirtualDom_noOnOrFormAction(key)
{
	return _VirtualDom_RE_on_formAction.test(key) ? 'data-' + key : key;
}

function _VirtualDom_noInnerHtmlOrFormAction(key)
{
	return key == 'innerHTML' || key == 'formAction' ? 'data-' + key : key;
}

function _VirtualDom_noJavaScriptUri(value)
{
	return _VirtualDom_RE_js.test(value)
		? /**_UNUSED/''//*//**/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return _VirtualDom_RE_js_html.test(value)
		? /**_UNUSED/''//*//**/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlJson(value)
{
	return (typeof _Json_unwrap(value) === 'string' && _VirtualDom_RE_js_html.test(_Json_unwrap(value)))
		? _Json_wrap(
			/**_UNUSED/''//*//**/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		) : value;
}



// MAP FACTS


var _VirtualDom_mapAttribute = F2(function(func, attr)
{
	return (attr.$ === 'a0')
		? A2(_VirtualDom_on, attr.n, _VirtualDom_mapHandler(func, attr.o))
		: attr;
});

function _VirtualDom_mapHandler(func, handler)
{
	var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2($elm$json$Json$Decode$map, func, handler.a)
				:
			A3($elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				$elm$json$Json$Decode$succeed(func),
				handler.a
			)
	};
}

var _VirtualDom_mapEventTuple = F2(function(func, tuple)
{
	return _Utils_Tuple2(func(tuple.a), tuple.b);
});

var _VirtualDom_mapEventRecord = F2(function(func, record)
{
	return {
		message: func(record.message),
		stopPropagation: record.stopPropagation,
		preventDefault: record.preventDefault
	}
});



// ORGANIZE FACTS


function _VirtualDom_organizeFacts(factList)
{
	for (var facts = {}; factList.b; factList = factList.b) // WHILE_CONS
	{
		var entry = factList.a;

		var tag = entry.$;
		var key = entry.n;
		var value = entry.o;

		if (tag === 'a2')
		{
			(key === 'className')
				? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
				: facts[key] = _Json_unwrap(value);

			continue;
		}

		var subFacts = facts[tag] || (facts[tag] = {});
		(tag === 'a3' && key === 'class')
			? _VirtualDom_addClass(subFacts, key, value)
			: subFacts[key] = value;
	}

	return facts;
}

function _VirtualDom_addClass(object, key, newClass)
{
	var classes = object[key];
	object[key] = classes ? classes + ' ' + newClass : newClass;
}



// RENDER


function _VirtualDom_render(vNode, eventNode)
{
	var tag = vNode.$;

	if (tag === 5)
	{
		return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
	}

	if (tag === 0)
	{
		return _VirtualDom_doc.createTextNode(vNode.a);
	}

	if (tag === 4)
	{
		var subNode = vNode.k;
		var tagger = vNode.j;

		while (subNode.$ === 4)
		{
			typeof tagger !== 'object'
				? tagger = [tagger, subNode.j]
				: tagger.push(subNode.j);

			subNode = subNode.k;
		}

		var subEventRoot = { j: tagger, p: eventNode };
		var domNode = _VirtualDom_render(subNode, subEventRoot);
		domNode.elm_event_node_ref = subEventRoot;
		return domNode;
	}

	if (tag === 3)
	{
		var domNode = vNode.h(vNode.g);
		_VirtualDom_applyFacts(domNode, eventNode, vNode.d);
		return domNode;
	}

	// at this point `tag` must be 1 or 2

	var domNode = vNode.f
		? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
		: _VirtualDom_doc.createElement(vNode.c);

	if (_VirtualDom_divertHrefToApp && vNode.c == 'a')
	{
		domNode.addEventListener('click', _VirtualDom_divertHrefToApp(domNode));
	}

	_VirtualDom_applyFacts(domNode, eventNode, vNode.d);

	for (var kids = vNode.e, i = 0; i < kids.length; i++)
	{
		_VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
	}

	return domNode;
}



// APPLY FACTS


function _VirtualDom_applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		key === 'a1'
			? _VirtualDom_applyStyles(domNode, value)
			:
		key === 'a0'
			? _VirtualDom_applyEvents(domNode, eventNode, value)
			:
		key === 'a3'
			? _VirtualDom_applyAttrs(domNode, value)
			:
		key === 'a4'
			? _VirtualDom_applyAttrsNS(domNode, value)
			:
		((key !== 'value' && key !== 'checked') || domNode[key] !== value) && (domNode[key] = value);
	}
}



// APPLY STYLES


function _VirtualDom_applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}



// APPLY ATTRS


function _VirtualDom_applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		typeof value !== 'undefined'
			? domNode.setAttribute(key, value)
			: domNode.removeAttribute(key);
	}
}



// APPLY NAMESPACED ATTRS


function _VirtualDom_applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.f;
		var value = pair.o;

		typeof value !== 'undefined'
			? domNode.setAttributeNS(namespace, key, value)
			: domNode.removeAttributeNS(namespace, key);
	}
}



// APPLY EVENTS


function _VirtualDom_applyEvents(domNode, eventNode, events)
{
	var allCallbacks = domNode.elmFs || (domNode.elmFs = {});

	for (var key in events)
	{
		var newHandler = events[key];
		var oldCallback = allCallbacks[key];

		if (!newHandler)
		{
			domNode.removeEventListener(key, oldCallback);
			allCallbacks[key] = undefined;
			continue;
		}

		if (oldCallback)
		{
			var oldHandler = oldCallback.q;
			if (oldHandler.$ === newHandler.$)
			{
				oldCallback.q = newHandler;
				continue;
			}
			domNode.removeEventListener(key, oldCallback);
		}

		oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
		domNode.addEventListener(key, oldCallback,
			_VirtualDom_passiveSupported
			&& { passive: $elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
		);
		allCallbacks[key] = oldCallback;
	}
}



// PASSIVE EVENTS


var _VirtualDom_passiveSupported;

try
{
	window.addEventListener('t', null, Object.defineProperty({}, 'passive', {
		get: function() { _VirtualDom_passiveSupported = true; }
	}));
}
catch(e) {}



// EVENT HANDLERS


function _VirtualDom_makeCallback(eventNode, initialHandler)
{
	function callback(event)
	{
		var handler = callback.q;
		var result = _Json_runHelp(handler.a, event);

		if (!$elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

		// 0 = Normal
		// 1 = MayStopPropagation
		// 2 = MayPreventDefault
		// 3 = Custom

		var value = result.a;
		var message = !tag ? value : tag < 3 ? value.a : value.message;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.stopPropagation;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value.preventDefault) && event.preventDefault(),
			eventNode
		);
		var tagger;
		var i;
		while (tagger = currentEventNode.j)
		{
			if (typeof tagger == 'function')
			{
				message = tagger(message);
			}
			else
			{
				for (var i = tagger.length; i--; )
				{
					message = tagger[i](message);
				}
			}
			currentEventNode = currentEventNode.p;
		}
		currentEventNode(message, stopPropagation); // stopPropagation implies isSync
	}

	callback.q = initialHandler;

	return callback;
}

function _VirtualDom_equalEvents(x, y)
{
	return x.$ == y.$ && _Json_equality(x.a, y.a);
}



// DIFF


// TODO: Should we do patches like in iOS?
//
// type Patch
//   = At Int Patch
//   | Batch (List Patch)
//   | Change ...
//
// How could it not be better?
//
function _VirtualDom_diff(x, y)
{
	var patches = [];
	_VirtualDom_diffHelp(x, y, patches, 0);
	return patches;
}


function _VirtualDom_pushPatch(patches, type, index, data)
{
	var patch = {
		$: type,
		r: index,
		s: data,
		t: undefined,
		u: undefined
	};
	patches.push(patch);
	return patch;
}


function _VirtualDom_diffHelp(x, y, patches, index)
{
	if (x === y)
	{
		return;
	}

	var xType = x.$;
	var yType = y.$;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (xType !== yType)
	{
		if (xType === 1 && yType === 2)
		{
			y = _VirtualDom_dekey(y);
			yType = 1;
		}
		else
		{
			_VirtualDom_pushPatch(patches, 0, index, y);
			return;
		}
	}

	// Now we know that both nodes are the same $.
	switch (yType)
	{
		case 5:
			var xRefs = x.l;
			var yRefs = y.l;
			var i = xRefs.length;
			var same = i === yRefs.length;
			while (same && i--)
			{
				same = xRefs[i] === yRefs[i];
			}
			if (same)
			{
				y.k = x.k;
				return;
			}
			y.k = y.m();
			var subPatches = [];
			_VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
			subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
			return;

		case 4:
			// gather nested taggers
			var xTaggers = x.j;
			var yTaggers = y.j;
			var nesting = false;

			var xSubNode = x.k;
			while (xSubNode.$ === 4)
			{
				nesting = true;

				typeof xTaggers !== 'object'
					? xTaggers = [xTaggers, xSubNode.j]
					: xTaggers.push(xSubNode.j);

				xSubNode = xSubNode.k;
			}

			var ySubNode = y.k;
			while (ySubNode.$ === 4)
			{
				nesting = true;

				typeof yTaggers !== 'object'
					? yTaggers = [yTaggers, ySubNode.j]
					: yTaggers.push(ySubNode.j);

				ySubNode = ySubNode.k;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && xTaggers.length !== yTaggers.length)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers)
			{
				_VirtualDom_pushPatch(patches, 2, index, yTaggers);
			}

			// diff everything below the taggers
			_VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
			return;

		case 0:
			if (x.a !== y.a)
			{
				_VirtualDom_pushPatch(patches, 3, index, y.a);
			}
			return;

		case 1:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
			return;

		case 2:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
			return;

		case 3:
			if (x.h !== y.h)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
			factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

			var patch = y.i(x.g, y.g);
			patch && _VirtualDom_pushPatch(patches, 5, index, patch);

			return;
	}
}

// assumes the incoming arrays are the same length
function _VirtualDom_pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}

function _VirtualDom_diffNodes(x, y, patches, index, diffKids)
{
	// Bail if obvious indicators have changed. Implies more serious
	// structural changes such that it's not worth it to diff.
	if (x.c !== y.c || x.f !== y.f)
	{
		_VirtualDom_pushPatch(patches, 0, index, y);
		return;
	}

	var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
	factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

	diffKids(x, y, patches, index);
}



// DIFF FACTS


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function _VirtualDom_diffFacts(x, y, category)
{
	var diff;

	// look for changes and removals
	for (var xKey in x)
	{
		if (xKey === 'a1' || xKey === 'a0' || xKey === 'a3' || xKey === 'a4')
		{
			var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[xKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(xKey in y))
		{
			diff = diff || {};
			diff[xKey] =
				!category
					? (typeof x[xKey] === 'string' ? '' : null)
					:
				(category === 'a1')
					? ''
					:
				(category === 'a0' || category === 'a3')
					? undefined
					:
				{ f: x[xKey].f, o: undefined };

			continue;
		}

		var xValue = x[xKey];
		var yValue = y[xKey];

		// reference equal, so don't worry about it
		if (xValue === yValue && xKey !== 'value' && xKey !== 'checked'
			|| category === 'a0' && _VirtualDom_equalEvents(xValue, yValue))
		{
			continue;
		}

		diff = diff || {};
		diff[xKey] = yValue;
	}

	// add new stuff
	for (var yKey in y)
	{
		if (!(yKey in x))
		{
			diff = diff || {};
			diff[yKey] = y[yKey];
		}
	}

	return diff;
}



// DIFF KIDS


function _VirtualDom_diffKids(xParent, yParent, patches, index)
{
	var xKids = xParent.e;
	var yKids = yParent.e;

	var xLen = xKids.length;
	var yLen = yKids.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (xLen > yLen)
	{
		_VirtualDom_pushPatch(patches, 6, index, {
			v: yLen,
			i: xLen - yLen
		});
	}
	else if (xLen < yLen)
	{
		_VirtualDom_pushPatch(patches, 7, index, {
			v: xLen,
			e: yKids
		});
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++)
	{
		var xKid = xKids[i];
		_VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
		index += xKid.b || 0;
	}
}



// KEYED DIFF


function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var xKids = xParent.e;
	var yKids = yParent.e;
	var xLen = xKids.length;
	var yLen = yKids.length;
	var xIndex = 0;
	var yIndex = 0;

	var index = rootIndex;

	while (xIndex < xLen && yIndex < yLen)
	{
		var x = xKids[xIndex];
		var y = yKids[yIndex];

		var xKey = x.a;
		var yKey = y.a;
		var xNode = x.b;
		var yNode = y.b;

		var newMatch = undefined;
		var oldMatch = undefined;

		// check if keys match

		if (xKey === yKey)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNode, localPatches, index);
			index += xNode.b || 0;

			xIndex++;
			yIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var xNext = xKids[xIndex + 1];
		var yNext = yKids[yIndex + 1];

		if (xNext)
		{
			var xNextKey = xNext.a;
			var xNextNode = xNext.b;
			oldMatch = yKey === xNextKey;
		}

		if (yNext)
		{
			var yNextKey = yNext.a;
			var yNextNode = yNext.b;
			newMatch = xKey === yNextKey;
		}


		// swap x and y
		if (newMatch && oldMatch)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			_VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		// insert y
		if (newMatch)
		{
			index++;
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			index += xNode.b || 0;

			xIndex += 1;
			yIndex += 2;
			continue;
		}

		// remove x
		if (oldMatch)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 1;
			continue;
		}

		// remove x, insert y
		if (xNext && xNextKey === yNextKey)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (xIndex < xLen)
	{
		index++;
		var x = xKids[xIndex];
		var xNode = x.b;
		_VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
		index += xNode.b || 0;
		xIndex++;
	}

	while (yIndex < yLen)
	{
		var endInserts = endInserts || [];
		var y = yKids[yIndex];
		_VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
		yIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || endInserts)
	{
		_VirtualDom_pushPatch(patches, 8, rootIndex, {
			w: localPatches,
			x: inserts,
			y: endInserts
		});
	}
}



// CHANGES FROM KEYED DIFF


var _VirtualDom_POSTFIX = '_elmW6BL';


function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		entry = {
			c: 0,
			z: vnode,
			r: yIndex,
			s: undefined
		};

		inserts.push({ r: yIndex, A: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.c === 1)
	{
		inserts.push({ r: yIndex, A: entry });

		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
		entry.r = yIndex;
		entry.s.s = {
			w: subPatches,
			A: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	_VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
}


function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);

		changes[key] = {
			c: 1,
			z: vnode,
			r: index,
			s: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.c === 0)
	{
		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(vnode, entry.z, subPatches, index);

		_VirtualDom_pushPatch(localPatches, 9, index, {
			w: subPatches,
			A: entry
		});

		return;
	}

	// this key has already been removed or moved, a duplicate!
	_VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
}



// ADD DOM NODES
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)
{
	_VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.r;

	while (index === low)
	{
		var patchType = patch.$;

		if (patchType === 1)
		{
			_VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
		}
		else if (patchType === 8)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var subPatches = patch.s.w;
			if (subPatches.length > 0)
			{
				_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 9)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var data = patch.s;
			if (data)
			{
				data.A.s = domNode;
				var subPatches = data.w;
				if (subPatches.length > 0)
				{
					_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.t = domNode;
			patch.u = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.r) > high)
		{
			return i;
		}
	}

	var tag = vNode.$;

	if (tag === 4)
	{
		var subNode = vNode.k;

		while (subNode.$ === 4)
		{
			subNode = subNode.k;
		}

		return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
	}

	// tag must be 1 or 2 at this point

	var vKids = vNode.e;
	var childNodes = domNode.childNodes;
	for (var j = 0; j < vKids.length; j++)
	{
		low++;
		var vKid = tag === 1 ? vKids[j] : vKids[j].b;
		var nextLow = low + (vKid.b || 0);
		if (low <= index && index <= nextLow)
		{
			i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
			if (!(patch = patches[i]) || (index = patch.r) > high)
			{
				return i;
			}
		}
		low = nextLow;
	}
	return i;
}



// APPLY PATCHES


function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	_VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
}

function _VirtualDom_applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.t
		var newNode = _VirtualDom_applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function _VirtualDom_applyPatch(domNode, patch)
{
	switch (patch.$)
	{
		case 0:
			return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);

		case 4:
			_VirtualDom_applyFacts(domNode, patch.u, patch.s);
			return domNode;

		case 3:
			domNode.replaceData(0, domNode.length, patch.s);
			return domNode;

		case 1:
			return _VirtualDom_applyPatchesHelp(domNode, patch.s);

		case 2:
			if (domNode.elm_event_node_ref)
			{
				domNode.elm_event_node_ref.j = patch.s;
			}
			else
			{
				domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
			}
			return domNode;

		case 6:
			var data = patch.s;
			for (var i = 0; i < data.i; i++)
			{
				domNode.removeChild(domNode.childNodes[data.v]);
			}
			return domNode;

		case 7:
			var data = patch.s;
			var kids = data.e;
			var i = data.v;
			var theEnd = domNode.childNodes[i];
			for (; i < kids.length; i++)
			{
				domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
			}
			return domNode;

		case 9:
			var data = patch.s;
			if (!data)
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.A;
			if (typeof entry.r !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
			return domNode;

		case 8:
			return _VirtualDom_applyPatchReorder(domNode, patch);

		case 5:
			return patch.s(domNode);

		default:
			_Debug_crash(10); // 'Ran into an unknown patch!'
	}
}


function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = _VirtualDom_render(vNode, eventNode);

	if (!newNode.elm_event_node_ref)
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function _VirtualDom_applyPatchReorder(domNode, patch)
{
	var data = patch.s;

	// remove end inserts
	var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);

	// removals
	domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);

	// inserts
	var inserts = data.x;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.A;
		var node = entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u);
		domNode.insertBefore(node, domNode.childNodes[insert.r]);
	}

	// add end inserts
	if (frag)
	{
		_VirtualDom_appendChild(domNode, frag);
	}

	return domNode;
}


function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (!endInserts)
	{
		return;
	}

	var frag = _VirtualDom_doc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.A;
		_VirtualDom_appendChild(frag, entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u)
		);
	}
	return frag;
}


function _VirtualDom_virtualize(node)
{
	// TEXT NODES

	if (node.nodeType === 3)
	{
		return _VirtualDom_text(node.textContent);
	}


	// WEIRD NODES

	if (node.nodeType !== 1)
	{
		return _VirtualDom_text('');
	}


	// ELEMENT NODES

	var attrList = _List_Nil;
	var attrs = node.attributes;
	for (var i = attrs.length; i--; )
	{
		var attr = attrs[i];
		var name = attr.name;
		var value = attr.value;
		attrList = _List_Cons( A2(_VirtualDom_attribute, name, value), attrList );
	}

	var tag = node.tagName.toLowerCase();
	var kidList = _List_Nil;
	var kids = node.childNodes;

	for (var i = kids.length; i--; )
	{
		kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
	}
	return A3(_VirtualDom_node, tag, attrList, kidList);
}

function _VirtualDom_dekey(keyedNode)
{
	var keyedKids = keyedNode.e;
	var len = keyedKids.length;
	var kids = new Array(len);
	for (var i = 0; i < len; i++)
	{
		kids[i] = keyedKids[i].b;
	}

	return {
		$: 1,
		c: keyedNode.c,
		d: keyedNode.d,
		e: kids,
		f: keyedNode.f,
		b: keyedNode.b
	};
}




// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function(sendToApp, initialModel) {
			var view = impl.view;
			/**_UNUSED/
			var domNode = args['node'];
			//*/
			/**/
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			//*/
			var currNode = _VirtualDom_virtualize(domNode);

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = view(model);
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;
			});
		}
	);
});



// DOCUMENT


var _Debugger_document;

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.setup && impl.setup(sendToApp)
			var view = impl.view;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.body);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.title) && (_VirtualDom_doc.title = title = doc.title);
			});
		}
	);
});



// ANIMATION


var _Browser_cancelAnimationFrame =
	typeof cancelAnimationFrame !== 'undefined'
		? cancelAnimationFrame
		: function(id) { clearTimeout(id); };

var _Browser_requestAnimationFrame =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { return setTimeout(callback, 1000 / 60); };


function _Browser_makeAnimator(model, draw)
{
	draw(model);

	var state = 0;

	function updateIfNeeded()
	{
		state = state === 1
			? 0
			: ( _Browser_requestAnimationFrame(updateIfNeeded), draw(model), 1 );
	}

	return function(nextModel, isSync)
	{
		model = nextModel;

		isSync
			? ( draw(model),
				state === 2 && (state = 1)
				)
			: ( state === 0 && _Browser_requestAnimationFrame(updateIfNeeded),
				state = 2
				);
	};
}



// APPLICATION


function _Browser_application(impl)
{
	var onUrlChange = impl.onUrlChange;
	var onUrlRequest = impl.onUrlRequest;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		setup: function(sendToApp)
		{
			key.a = sendToApp;
			_Browser_window.addEventListener('popstate', key);
			_Browser_window.navigator.userAgent.indexOf('Trident') < 0 || _Browser_window.addEventListener('hashchange', key);

			return F2(function(domNode, event)
			{
				if (!event.ctrlKey && !event.metaKey && !event.shiftKey && event.button < 1 && !domNode.target && !domNode.hasAttribute('download'))
				{
					event.preventDefault();
					var href = domNode.href;
					var curr = _Browser_getUrl();
					var next = $elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.protocol === next.protocol
							&& curr.host === next.host
							&& curr.port_.a === next.port_.a
						)
							? $elm$browser$Browser$Internal(next)
							: $elm$browser$Browser$External(href)
					));
				}
			});
		},
		init: function(flags)
		{
			return A3(impl.init, flags, _Browser_getUrl(), key);
		},
		view: impl.view,
		update: impl.update,
		subscriptions: impl.subscriptions
	});
}

function _Browser_getUrl()
{
	return $elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.replaceState({}, '', url);
		key();
	}));
});



// GLOBAL EVENTS


var _Browser_fakeNode = { addEventListener: function() {}, removeEventListener: function() {} };
var _Browser_doc = typeof document !== 'undefined' ? document : _Browser_fakeNode;
var _Browser_window = typeof window !== 'undefined' ? window : _Browser_fakeNode;

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
	return _Scheduler_spawn(_Scheduler_binding(function(callback)
	{
		function handler(event)	{ _Scheduler_rawSpawn(sendToSelf(event)); }
		node.addEventListener(eventName, handler, _VirtualDom_passiveSupported && { passive: true });
		return function() { node.removeEventListener(eventName, handler); };
	}));
});

var _Browser_decodeEvent = F2(function(decoder, event)
{
	var result = _Json_runHelp(decoder, event);
	return $elm$core$Result$isOk(result) ? $elm$core$Maybe$Just(result.a) : $elm$core$Maybe$Nothing;
});



// PAGE VISIBILITY


function _Browser_visibilityInfo()
{
	return (typeof _VirtualDom_doc.hidden !== 'undefined')
		? { hidden: 'hidden', change: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { hidden: 'mozHidden', change: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { hidden: 'msHidden', change: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { hidden: 'webkitHidden', change: 'webkitvisibilitychange' }
		: { hidden: 'hidden', change: 'visibilitychange' };
}



// ANIMATION FRAMES


function _Browser_rAF()
{
	return _Scheduler_binding(function(callback)
	{
		var id = _Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(Date.now()));
		});

		return function() {
			_Browser_cancelAnimationFrame(id);
		};
	});
}


function _Browser_now()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}



// DOM STUFF


function _Browser_withNode(id, doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			var node = document.getElementById(id);
			callback(node
				? _Scheduler_succeed(doStuff(node))
				: _Scheduler_fail($elm$browser$Browser$Dom$NotFound(id))
			);
		});
	});
}


function _Browser_withWindow(doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(doStuff()));
		});
	});
}


// FOCUS and BLUR


var _Browser_call = F2(function(functionName, id)
{
	return _Browser_withNode(id, function(node) {
		node[functionName]();
		return _Utils_Tuple0;
	});
});



// WINDOW VIEWPORT


function _Browser_getViewport()
{
	return {
		scene: _Browser_getScene(),
		viewport: {
			x: _Browser_window.pageXOffset,
			y: _Browser_window.pageYOffset,
			width: _Browser_doc.documentElement.clientWidth,
			height: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		width: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		height: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
	};
}

var _Browser_setViewport = F2(function(x, y)
{
	return _Browser_withWindow(function()
	{
		_Browser_window.scroll(x, y);
		return _Utils_Tuple0;
	});
});



// ELEMENT VIEWPORT


function _Browser_getViewportOf(id)
{
	return _Browser_withNode(id, function(node)
	{
		return {
			scene: {
				width: node.scrollWidth,
				height: node.scrollHeight
			},
			viewport: {
				x: node.scrollLeft,
				y: node.scrollTop,
				width: node.clientWidth,
				height: node.clientHeight
			}
		};
	});
}


var _Browser_setViewportOf = F3(function(id, x, y)
{
	return _Browser_withNode(id, function(node)
	{
		node.scrollLeft = x;
		node.scrollTop = y;
		return _Utils_Tuple0;
	});
});



// ELEMENT


function _Browser_getElement(id)
{
	return _Browser_withNode(id, function(node)
	{
		var rect = node.getBoundingClientRect();
		var x = _Browser_window.pageXOffset;
		var y = _Browser_window.pageYOffset;
		return {
			scene: _Browser_getScene(),
			viewport: {
				x: x,
				y: y,
				width: _Browser_doc.documentElement.clientWidth,
				height: _Browser_doc.documentElement.clientHeight
			},
			element: {
				x: x + rect.left,
				y: y + rect.top,
				width: rect.width,
				height: rect.height
			}
		};
	});
}



// LOAD and RELOAD


function _Browser_reload(skipCache)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		try
		{
			_Browser_window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			_VirtualDom_doc.location.reload(false);
		}
	}));
}


// CREATE

var _Regex_never = /.^/;

var _Regex_fromStringWith = F2(function(options, string)
{
	var flags = 'g';
	if (options.multiline) { flags += 'm'; }
	if (options.caseInsensitive) { flags += 'i'; }

	try
	{
		return $elm$core$Maybe$Just(new RegExp(string, flags));
	}
	catch(error)
	{
		return $elm$core$Maybe$Nothing;
	}
});


// USE

var _Regex_contains = F2(function(re, string)
{
	return string.match(re) !== null;
});


var _Regex_findAtMost = F3(function(n, re, str)
{
	var out = [];
	var number = 0;
	var string = str;
	var lastIndex = re.lastIndex;
	var prevLastIndex = -1;
	var result;
	while (number++ < n && (result = re.exec(string)))
	{
		if (prevLastIndex == re.lastIndex) break;
		var i = result.length - 1;
		var subs = new Array(i);
		while (i > 0)
		{
			var submatch = result[i];
			subs[--i] = submatch
				? $elm$core$Maybe$Just(submatch)
				: $elm$core$Maybe$Nothing;
		}
		out.push(A4($elm$regex$Regex$Match, result[0], result.index, number, _List_fromArray(subs)));
		prevLastIndex = re.lastIndex;
	}
	re.lastIndex = lastIndex;
	return _List_fromArray(out);
});


var _Regex_replaceAtMost = F4(function(n, re, replacer, string)
{
	var count = 0;
	function jsReplacer(match)
	{
		if (count++ >= n)
		{
			return match;
		}
		var i = arguments.length - 3;
		var submatches = new Array(i);
		while (i > 0)
		{
			var submatch = arguments[i];
			submatches[--i] = submatch
				? $elm$core$Maybe$Just(submatch)
				: $elm$core$Maybe$Nothing;
		}
		return replacer(A4($elm$regex$Regex$Match, match, arguments[arguments.length - 2], count, _List_fromArray(submatches)));
	}
	return string.replace(re, jsReplacer);
});

var _Regex_splitAtMost = F3(function(n, re, str)
{
	var string = str;
	var out = [];
	var start = re.lastIndex;
	var restoreLastIndex = re.lastIndex;
	while (n--)
	{
		var result = re.exec(string);
		if (!result) break;
		out.push(string.slice(start, result.index));
		start = re.lastIndex;
	}
	out.push(string.slice(start));
	re.lastIndex = restoreLastIndex;
	return _List_fromArray(out);
});

var _Regex_infinity = Infinity;



// SEND REQUEST

var _Http_toTask = F3(function(router, toTask, request)
{
	return _Scheduler_binding(function(callback)
	{
		function done(response) {
			callback(toTask(request.expect.a(response)));
		}

		var xhr = new XMLHttpRequest();
		xhr.addEventListener('error', function() { done($elm$http$Http$NetworkError_); });
		xhr.addEventListener('timeout', function() { done($elm$http$Http$Timeout_); });
		xhr.addEventListener('load', function() { done(_Http_toResponse(request.expect.b, xhr)); });
		$elm$core$Maybe$isJust(request.tracker) && _Http_track(router, xhr, request.tracker.a);

		try {
			xhr.open(request.method, request.url, true);
		} catch (e) {
			return done($elm$http$Http$BadUrl_(request.url));
		}

		_Http_configureRequest(xhr, request);

		request.body.a && xhr.setRequestHeader('Content-Type', request.body.a);
		xhr.send(request.body.b);

		return function() { xhr.c = true; xhr.abort(); };
	});
});


// CONFIGURE

function _Http_configureRequest(xhr, request)
{
	for (var headers = request.headers; headers.b; headers = headers.b) // WHILE_CONS
	{
		xhr.setRequestHeader(headers.a.a, headers.a.b);
	}
	xhr.timeout = request.timeout.a || 0;
	xhr.responseType = request.expect.d;
	xhr.withCredentials = request.allowCookiesFromOtherDomains;
}


// RESPONSES

function _Http_toResponse(toBody, xhr)
{
	return A2(
		200 <= xhr.status && xhr.status < 300 ? $elm$http$Http$GoodStatus_ : $elm$http$Http$BadStatus_,
		_Http_toMetadata(xhr),
		toBody(xhr.response)
	);
}


// METADATA

function _Http_toMetadata(xhr)
{
	return {
		url: xhr.responseURL,
		statusCode: xhr.status,
		statusText: xhr.statusText,
		headers: _Http_parseHeaders(xhr.getAllResponseHeaders())
	};
}


// HEADERS

function _Http_parseHeaders(rawHeaders)
{
	if (!rawHeaders)
	{
		return $elm$core$Dict$empty;
	}

	var headers = $elm$core$Dict$empty;
	var headerPairs = rawHeaders.split('\r\n');
	for (var i = headerPairs.length; i--; )
	{
		var headerPair = headerPairs[i];
		var index = headerPair.indexOf(': ');
		if (index > 0)
		{
			var key = headerPair.substring(0, index);
			var value = headerPair.substring(index + 2);

			headers = A3($elm$core$Dict$update, key, function(oldValue) {
				return $elm$core$Maybe$Just($elm$core$Maybe$isJust(oldValue)
					? value + ', ' + oldValue.a
					: value
				);
			}, headers);
		}
	}
	return headers;
}


// EXPECT

var _Http_expect = F3(function(type, toBody, toValue)
{
	return {
		$: 0,
		d: type,
		b: toBody,
		a: toValue
	};
});

var _Http_mapExpect = F2(function(func, expect)
{
	return {
		$: 0,
		d: expect.d,
		b: expect.b,
		a: function(x) { return func(expect.a(x)); }
	};
});

function _Http_toDataView(arrayBuffer)
{
	return new DataView(arrayBuffer);
}


// BODY and PARTS

var _Http_emptyBody = { $: 0 };
var _Http_pair = F2(function(a, b) { return { $: 0, a: a, b: b }; });

function _Http_toFormData(parts)
{
	for (var formData = new FormData(); parts.b; parts = parts.b) // WHILE_CONS
	{
		var part = parts.a;
		formData.append(part.a, part.b);
	}
	return formData;
}

var _Http_bytesToBlob = F2(function(mime, bytes)
{
	return new Blob([bytes], { type: mime });
});


// PROGRESS

function _Http_track(router, xhr, tracker)
{
	// TODO check out lengthComputable on loadstart event

	xhr.upload.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2($elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, $elm$http$Http$Sending({
			sent: event.loaded,
			size: event.total
		}))));
	});
	xhr.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2($elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, $elm$http$Http$Receiving({
			received: event.loaded,
			size: event.lengthComputable ? $elm$core$Maybe$Just(event.total) : $elm$core$Maybe$Nothing
		}))));
	});
}

function _Url_percentEncode(string)
{
	return encodeURIComponent(string);
}

function _Url_percentDecode(string)
{
	try
	{
		return $elm$core$Maybe$Just(decodeURIComponent(string));
	}
	catch (e)
	{
		return $elm$core$Maybe$Nothing;
	}
}


function _Time_now(millisToPosix)
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(millisToPosix(Date.now())));
	});
}

var _Time_setInterval = F2(function(interval, task)
{
	return _Scheduler_binding(function(callback)
	{
		var id = setInterval(function() { _Scheduler_rawSpawn(task); }, interval);
		return function() { clearInterval(id); };
	});
});

function _Time_here()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(
			A2($elm$time$Time$customZone, -(new Date().getTimezoneOffset()), _List_Nil)
		));
	});
}


function _Time_getZoneName()
{
	return _Scheduler_binding(function(callback)
	{
		try
		{
			var name = $elm$time$Time$Name(Intl.DateTimeFormat().resolvedOptions().timeZone);
		}
		catch (e)
		{
			var name = $elm$time$Time$Offset(new Date().getTimezoneOffset());
		}
		callback(_Scheduler_succeed(name));
	});
}




// STRINGS


var _Parser_isSubString = F5(function(smallString, offset, row, col, bigString)
{
	var smallLength = smallString.length;
	var isGood = offset + smallLength <= bigString.length;

	for (var i = 0; isGood && i < smallLength; )
	{
		var code = bigString.charCodeAt(offset);
		isGood =
			smallString[i++] === bigString[offset++]
			&& (
				code === 0x000A /* \n */
					? ( row++, col=1 )
					: ( col++, (code & 0xF800) === 0xD800 ? smallString[i++] === bigString[offset++] : 1 )
			)
	}

	return _Utils_Tuple3(isGood ? offset : -1, row, col);
});



// CHARS


var _Parser_isSubChar = F3(function(predicate, offset, string)
{
	return (
		string.length <= offset
			? -1
			:
		(string.charCodeAt(offset) & 0xF800) === 0xD800
			? (predicate(_Utils_chr(string.substr(offset, 2))) ? offset + 2 : -1)
			:
		(predicate(_Utils_chr(string[offset]))
			? ((string[offset] === '\n') ? -2 : (offset + 1))
			: -1
		)
	);
});


var _Parser_isAsciiCode = F3(function(code, offset, string)
{
	return string.charCodeAt(offset) === code;
});



// NUMBERS


var _Parser_chompBase10 = F2(function(offset, string)
{
	for (; offset < string.length; offset++)
	{
		var code = string.charCodeAt(offset);
		if (code < 0x30 || 0x39 < code)
		{
			return offset;
		}
	}
	return offset;
});


var _Parser_consumeBase = F3(function(base, offset, string)
{
	for (var total = 0; offset < string.length; offset++)
	{
		var digit = string.charCodeAt(offset) - 0x30;
		if (digit < 0 || base <= digit) break;
		total = base * total + digit;
	}
	return _Utils_Tuple2(offset, total);
});


var _Parser_consumeBase16 = F2(function(offset, string)
{
	for (var total = 0; offset < string.length; offset++)
	{
		var code = string.charCodeAt(offset);
		if (0x30 <= code && code <= 0x39)
		{
			total = 16 * total + code - 0x30;
		}
		else if (0x41 <= code && code <= 0x46)
		{
			total = 16 * total + code - 55;
		}
		else if (0x61 <= code && code <= 0x66)
		{
			total = 16 * total + code - 87;
		}
		else
		{
			break;
		}
	}
	return _Utils_Tuple2(offset, total);
});



// FIND STRING


var _Parser_findSubString = F5(function(smallString, offset, row, col, bigString)
{
	var newOffset = bigString.indexOf(smallString, offset);
	var target = newOffset < 0 ? bigString.length : newOffset + smallString.length;

	while (offset < target)
	{
		var code = bigString.charCodeAt(offset++);
		code === 0x000A /* \n */
			? ( col=1, row++ )
			: ( col++, (code & 0xF800) === 0xD800 && offset++ )
	}

	return _Utils_Tuple3(newOffset, row, col);
});



var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});
var $author$project$Main$UrlChanged = function (a) {
	return {$: 'UrlChanged', a: a};
};
var $author$project$Main$UrlRequested = function (a) {
	return {$: 'UrlRequested', a: a};
};
var $elm$core$List$cons = _List_cons;
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (node.$ === 'SubTree') {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0.a;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Basics$EQ = {$: 'EQ'};
var $elm$core$Basics$GT = {$: 'GT'};
var $elm$core$Basics$LT = {$: 'LT'};
var $elm$core$Result$Err = function (a) {
	return {$: 'Err', a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 'Failure', a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 'Field', a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 'Index', a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 'Ok', a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 'OneOf', a: a};
};
var $elm$core$Basics$False = {$: 'False'};
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 'Just', a: a};
};
var $elm$core$Maybe$Nothing = {$: 'Nothing'};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 'Field':
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 'Nothing') {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'Index':
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'OneOf':
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 'Array_elm_builtin', a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 'Leaf', a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 'SubTree', a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.nodeListSize) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.tail);
		} else {
			var treeLen = builder.nodeListSize * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.nodeList) : builder.nodeList;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.nodeListSize);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.tail);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{nodeList: nodeList, nodeListSize: (len / $elm$core$Array$branchFactor) | 0, tail: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = {$: 'True'};
var $elm$core$Result$isOk = function (result) {
	if (result.$ === 'Ok') {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $elm$json$Json$Decode$map = _Json_map1;
var $elm$json$Json$Decode$map2 = _Json_map2;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 'Normal':
			return 0;
		case 'MayStopPropagation':
			return 1;
		case 'MayPreventDefault':
			return 2;
		default:
			return 3;
	}
};
var $elm$browser$Browser$External = function (a) {
	return {$: 'External', a: a};
};
var $elm$browser$Browser$Internal = function (a) {
	return {$: 'Internal', a: a};
};
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $elm$browser$Browser$Dom$NotFound = function (a) {
	return {$: 'NotFound', a: a};
};
var $elm$url$Url$Http = {$: 'Http'};
var $elm$url$Url$Https = {$: 'Https'};
var $elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {fragment: fragment, host: host, path: path, port_: port_, protocol: protocol, query: query};
	});
var $elm$core$String$contains = _String_contains;
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $elm$core$String$indexes = _String_indexes;
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $elm$core$String$toInt = _String_toInt;
var $elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if ($elm$core$String$isEmpty(str) || A2($elm$core$String$contains, '@', str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, ':', str);
			if (!_v0.b) {
				return $elm$core$Maybe$Just(
					A6($elm$url$Url$Url, protocol, str, $elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_v0.b.b) {
					var i = _v0.a;
					var _v1 = $elm$core$String$toInt(
						A2($elm$core$String$dropLeft, i + 1, str));
					if (_v1.$ === 'Nothing') {
						return $elm$core$Maybe$Nothing;
					} else {
						var port_ = _v1;
						return $elm$core$Maybe$Just(
							A6(
								$elm$url$Url$Url,
								protocol,
								A2($elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		}
	});
var $elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '/', str);
			if (!_v0.b) {
				return A5($elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _v0.a;
				return A5(
					$elm$url$Url$chompBeforePath,
					protocol,
					A2($elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '?', str);
			if (!_v0.b) {
				return A4($elm$url$Url$chompBeforeQuery, protocol, $elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _v0.a;
				return A4(
					$elm$url$Url$chompBeforeQuery,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '#', str);
			if (!_v0.b) {
				return A3($elm$url$Url$chompBeforeFragment, protocol, $elm$core$Maybe$Nothing, str);
			} else {
				var i = _v0.a;
				return A3(
					$elm$url$Url$chompBeforeFragment,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$core$String$startsWith = _String_startsWith;
var $elm$url$Url$fromString = function (str) {
	return A2($elm$core$String$startsWith, 'http://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		$elm$url$Url$Http,
		A2($elm$core$String$dropLeft, 7, str)) : (A2($elm$core$String$startsWith, 'https://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		$elm$url$Url$Https,
		A2($elm$core$String$dropLeft, 8, str)) : $elm$core$Maybe$Nothing);
};
var $elm$core$Basics$never = function (_v0) {
	never:
	while (true) {
		var nvr = _v0.a;
		var $temp$_v0 = nvr;
		_v0 = $temp$_v0;
		continue never;
	}
};
var $elm$core$Task$Perform = function (a) {
	return {$: 'Perform', a: a};
};
var $elm$core$Task$succeed = _Scheduler_succeed;
var $elm$core$Task$init = $elm$core$Task$succeed(_Utils_Tuple0);
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $elm$core$Task$andThen = _Scheduler_andThen;
var $elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return $elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var $elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return A2(
					$elm$core$Task$andThen,
					function (b) {
						return $elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var $elm$core$Task$sequence = function (tasks) {
	return A3(
		$elm$core$List$foldr,
		$elm$core$Task$map2($elm$core$List$cons),
		$elm$core$Task$succeed(_List_Nil),
		tasks);
};
var $elm$core$Platform$sendToApp = _Platform_sendToApp;
var $elm$core$Task$spawnCmd = F2(
	function (router, _v0) {
		var task = _v0.a;
		return _Scheduler_spawn(
			A2(
				$elm$core$Task$andThen,
				$elm$core$Platform$sendToApp(router),
				task));
	});
var $elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			$elm$core$Task$map,
			function (_v0) {
				return _Utils_Tuple0;
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Task$spawnCmd(router),
					commands)));
	});
var $elm$core$Task$onSelfMsg = F3(
	function (_v0, _v1, _v2) {
		return $elm$core$Task$succeed(_Utils_Tuple0);
	});
var $elm$core$Task$cmdMap = F2(
	function (tagger, _v0) {
		var task = _v0.a;
		return $elm$core$Task$Perform(
			A2($elm$core$Task$map, tagger, task));
	});
_Platform_effectManagers['Task'] = _Platform_createManager($elm$core$Task$init, $elm$core$Task$onEffects, $elm$core$Task$onSelfMsg, $elm$core$Task$cmdMap);
var $elm$core$Task$command = _Platform_leaf('Task');
var $elm$core$Task$perform = F2(
	function (toMessage, task) {
		return $elm$core$Task$command(
			$elm$core$Task$Perform(
				A2($elm$core$Task$map, toMessage, task)));
	});
var $elm$browser$Browser$application = _Browser_application;
var $elm$json$Json$Decode$field = _Json_decodeField;
var $author$project$Main$Blank = {$: 'Blank'};
var $author$project$Util$Left = function (a) {
	return {$: 'Left', a: a};
};
var $author$project$Main$NoneLayout = {$: 'NoneLayout'};
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $elm$browser$Browser$Navigation$pushUrl = _Browser_pushUrl;
var $author$project$Main$init = F3(
	function (_v0, url, key) {
		var token = _v0.token;
		return _Utils_Tuple2(
			{
				key: key,
				layout: $author$project$Main$NoneLayout,
				page: $author$project$Main$Blank,
				token: $author$project$Util$Left(token),
				url: url
			},
			$elm$core$Platform$Cmd$batch(
				_List_fromArray(
					[
						A2($elm$browser$Browser$Navigation$pushUrl, key, '/login')
					])));
	});
var $elm$json$Json$Decode$string = _Json_decodeString;
var $elm$core$Platform$Sub$batch = _Platform_batch;
var $elm$core$Platform$Sub$none = $elm$core$Platform$Sub$batch(_List_Nil);
var $author$project$Main$subscriptions = function (_v0) {
	return $elm$core$Platform$Sub$none;
};
var $author$project$Main$CourseListPage = function (a) {
	return {$: 'CourseListPage', a: a};
};
var $author$project$Main$CourseListPageMsg = function (a) {
	return {$: 'CourseListPageMsg', a: a};
};
var $author$project$Main$CoursePage = function (a) {
	return {$: 'CoursePage', a: a};
};
var $author$project$Main$CoursePageMsg = function (a) {
	return {$: 'CoursePageMsg', a: a};
};
var $author$project$Main$DefaultLayout = function (a) {
	return {$: 'DefaultLayout', a: a};
};
var $author$project$Main$DefaultLayoutMsg = function (a) {
	return {$: 'DefaultLayoutMsg', a: a};
};
var $author$project$Main$Login = function (a) {
	return {$: 'Login', a: a};
};
var $author$project$Main$LoginMsg = function (a) {
	return {$: 'LoginMsg', a: a};
};
var $author$project$Main$MainPage = {$: 'MainPage'};
var $author$project$Main$NotFound = {$: 'NotFound'};
var $author$project$Util$Right = function (a) {
	return {$: 'Right', a: a};
};
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(_Utils_Tuple0),
			pairs));
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$Ports$setStorage = _Platform_outgoingPort(
	'setStorage',
	function ($) {
		return $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'key',
					$elm$json$Json$Encode$string($.key)),
					_Utils_Tuple2(
					'value',
					$elm$json$Json$Encode$string($.value))
				]));
	});
var $author$project$Page$Login$doSaveToken = function (token) {
	return $author$project$Ports$setStorage(
		{key: 'token', value: token});
};
var $author$project$Util$either_map = F3(
	function (fl, fr, e) {
		if (e.$ === 'Left') {
			var a = e.a;
			return fl(a);
		} else {
			var b = e.a;
			return fr(b);
		}
	});
var $author$project$Page$CourseListPage$GroupByClass = {$: 'GroupByClass'};
var $author$project$Page$CourseListPage$Loading = {$: 'Loading'};
var $author$project$Page$CourseListPage$CourseListFetchFailed = function (a) {
	return {$: 'CourseListFetchFailed', a: a};
};
var $author$project$Page$CourseListPage$GotCourses = function (a) {
	return {$: 'GotCourses', a: a};
};
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $author$project$Api$Data$CourseRead = F8(
	function (id, forSpecialization, logo, cover, title, description, forClass, forGroup) {
		return {cover: cover, description: description, forClass: forClass, forGroup: forGroup, forSpecialization: forSpecialization, id: id, logo: logo, title: title};
	});
var $author$project$Api$Data$decodeChain = $elm$json$Json$Decode$map2($elm$core$Basics$apR);
var $author$project$Api$Data$decode = F2(
	function (key, decoder) {
		return $author$project$Api$Data$decodeChain(
			A2($elm$json$Json$Decode$field, key, decoder));
	});
var $elm$json$Json$Decode$decodeValue = _Json_run;
var $elm$json$Json$Decode$fail = _Json_fail;
var $elm$json$Json$Decode$null = _Json_decodeNull;
var $elm$json$Json$Decode$oneOf = _Json_oneOf;
var $elm$json$Json$Decode$value = _Json_decodeValue;
var $author$project$Api$Data$maybeField = F3(
	function (key, decoder, fallback) {
		var valueDecoder = $elm$json$Json$Decode$oneOf(
			_List_fromArray(
				[
					A2($elm$json$Json$Decode$map, $elm$core$Maybe$Just, decoder),
					$elm$json$Json$Decode$null(fallback)
				]));
		var fieldDecoder = A2($elm$json$Json$Decode$field, key, $elm$json$Json$Decode$value);
		var decodeObject = function (rawObject) {
			var _v0 = A2($elm$json$Json$Decode$decodeValue, fieldDecoder, rawObject);
			if (_v0.$ === 'Ok') {
				var rawValue = _v0.a;
				var _v1 = A2($elm$json$Json$Decode$decodeValue, valueDecoder, rawValue);
				if (_v1.$ === 'Ok') {
					var value = _v1.a;
					return $elm$json$Json$Decode$succeed(value);
				} else {
					var error = _v1.a;
					return $elm$json$Json$Decode$fail(
						$elm$json$Json$Decode$errorToString(error));
				}
			} else {
				return $elm$json$Json$Decode$succeed(fallback);
			}
		};
		return A2($elm$json$Json$Decode$andThen, decodeObject, $elm$json$Json$Decode$value);
	});
var $author$project$Api$Data$decodeNullable = F2(
	function (key, decoder) {
		return $author$project$Api$Data$decodeChain(
			A3($author$project$Api$Data$maybeField, key, decoder, $elm$core$Maybe$Nothing));
	});
var $danyx23$elm_uuid$Uuid$Uuid = function (a) {
	return {$: 'Uuid', a: a};
};
var $elm$regex$Regex$Match = F4(
	function (match, index, number, submatches) {
		return {index: index, match: match, number: number, submatches: submatches};
	});
var $elm$regex$Regex$contains = _Regex_contains;
var $elm$regex$Regex$fromStringWith = _Regex_fromStringWith;
var $elm$regex$Regex$fromString = function (string) {
	return A2(
		$elm$regex$Regex$fromStringWith,
		{caseInsensitive: false, multiline: false},
		string);
};
var $elm$regex$Regex$never = _Regex_never;
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $danyx23$elm_uuid$Uuid$Barebones$uuidRegex = A2(
	$elm$core$Maybe$withDefault,
	$elm$regex$Regex$never,
	$elm$regex$Regex$fromString('^[0-9A-Fa-f]{8,8}-[0-9A-Fa-f]{4,4}-[1-5][0-9A-Fa-f]{3,3}-[8-9A-Ba-b][0-9A-Fa-f]{3,3}-[0-9A-Fa-f]{12,12}$'));
var $danyx23$elm_uuid$Uuid$Barebones$isValidUuid = function (uuidAsString) {
	return A2($elm$regex$Regex$contains, $danyx23$elm_uuid$Uuid$Barebones$uuidRegex, uuidAsString);
};
var $elm$core$String$toLower = _String_toLower;
var $danyx23$elm_uuid$Uuid$fromString = function (text) {
	return $danyx23$elm_uuid$Uuid$Barebones$isValidUuid(text) ? $elm$core$Maybe$Just(
		$danyx23$elm_uuid$Uuid$Uuid(
			$elm$core$String$toLower(text))) : $elm$core$Maybe$Nothing;
};
var $danyx23$elm_uuid$Uuid$decoder = A2(
	$elm$json$Json$Decode$andThen,
	function (string) {
		var _v0 = $danyx23$elm_uuid$Uuid$fromString(string);
		if (_v0.$ === 'Just') {
			var uuid = _v0.a;
			return $elm$json$Json$Decode$succeed(uuid);
		} else {
			return $elm$json$Json$Decode$fail('Not a valid UUID');
		}
	},
	$elm$json$Json$Decode$string);
var $author$project$Api$Data$EducationSpecialization = F3(
	function (id, name, department) {
		return {department: department, id: id, name: name};
	});
var $author$project$Api$Data$maybeDecode = F3(
	function (key, decoder, fallback) {
		return $author$project$Api$Data$decodeChain(
			A3($author$project$Api$Data$maybeField, key, decoder, fallback));
	});
var $author$project$Api$Data$educationSpecializationDecoder = A3(
	$author$project$Api$Data$decode,
	'department',
	$danyx23$elm_uuid$Uuid$decoder,
	A3(
		$author$project$Api$Data$decode,
		'name',
		$elm$json$Json$Decode$string,
		A4(
			$author$project$Api$Data$maybeDecode,
			'id',
			$danyx23$elm_uuid$Uuid$decoder,
			$elm$core$Maybe$Nothing,
			$elm$json$Json$Decode$succeed($author$project$Api$Data$EducationSpecialization))));
var $author$project$Api$Data$File = F5(
	function (id, name, hash, size, mimeType) {
		return {hash: hash, id: id, mimeType: mimeType, name: name, size: size};
	});
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $author$project$Api$Data$fileDecoder = A3(
	$author$project$Api$Data$decode,
	'mime_type',
	$elm$json$Json$Decode$string,
	A3(
		$author$project$Api$Data$decode,
		'size',
		$elm$json$Json$Decode$int,
		A3(
			$author$project$Api$Data$decode,
			'hash',
			$elm$json$Json$Decode$string,
			A3(
				$author$project$Api$Data$decode,
				'name',
				$elm$json$Json$Decode$string,
				A4(
					$author$project$Api$Data$maybeDecode,
					'id',
					$danyx23$elm_uuid$Uuid$decoder,
					$elm$core$Maybe$Nothing,
					$elm$json$Json$Decode$succeed($author$project$Api$Data$File))))));
var $author$project$Api$Data$maybeDecodeNullable = F3(
	function (key, decoder, fallback) {
		return $author$project$Api$Data$decodeChain(
			A3($author$project$Api$Data$maybeField, key, decoder, fallback));
	});
var $author$project$Api$Data$courseReadDecoder = A4(
	$author$project$Api$Data$maybeDecodeNullable,
	'for_group',
	$elm$json$Json$Decode$string,
	$elm$core$Maybe$Nothing,
	A4(
		$author$project$Api$Data$maybeDecode,
		'for_class',
		$elm$json$Json$Decode$string,
		$elm$core$Maybe$Nothing,
		A3(
			$author$project$Api$Data$decode,
			'description',
			$elm$json$Json$Decode$string,
			A3(
				$author$project$Api$Data$decode,
				'title',
				$elm$json$Json$Decode$string,
				A3(
					$author$project$Api$Data$decodeNullable,
					'cover',
					$author$project$Api$Data$fileDecoder,
					A3(
						$author$project$Api$Data$decodeNullable,
						'logo',
						$author$project$Api$Data$fileDecoder,
						A3(
							$author$project$Api$Data$decodeNullable,
							'for_specialization',
							$author$project$Api$Data$educationSpecializationDecoder,
							A4(
								$author$project$Api$Data$maybeDecode,
								'id',
								$danyx23$elm_uuid$Uuid$decoder,
								$elm$core$Maybe$Nothing,
								$elm$json$Json$Decode$succeed($author$project$Api$Data$CourseRead)))))))));
var $elm$json$Json$Decode$list = _Json_decodeList;
var $author$project$Api$Request = function (a) {
	return {$: 'Request', a: a};
};
var $elm$http$Http$BadStatus_ = F2(
	function (a, b) {
		return {$: 'BadStatus_', a: a, b: b};
	});
var $elm$http$Http$BadUrl_ = function (a) {
	return {$: 'BadUrl_', a: a};
};
var $elm$http$Http$GoodStatus_ = F2(
	function (a, b) {
		return {$: 'GoodStatus_', a: a, b: b};
	});
var $elm$http$Http$NetworkError_ = {$: 'NetworkError_'};
var $elm$http$Http$Receiving = function (a) {
	return {$: 'Receiving', a: a};
};
var $elm$http$Http$Sending = function (a) {
	return {$: 'Sending', a: a};
};
var $elm$http$Http$Timeout_ = {$: 'Timeout_'};
var $elm$core$Dict$RBEmpty_elm_builtin = {$: 'RBEmpty_elm_builtin'};
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $elm$core$Maybe$isJust = function (maybe) {
	if (maybe.$ === 'Just') {
		return true;
	} else {
		return false;
	}
};
var $elm$core$Platform$sendToSelf = _Platform_sendToSelf;
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1.$) {
					case 'LT':
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 'EQ':
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $elm$core$Dict$Black = {$: 'Black'};
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: 'RBNode_elm_builtin', a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$Red = {$: 'Red'};
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Red')) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) && (left.d.$ === 'RBNode_elm_builtin')) && (left.d.a.$ === 'Red')) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1.$) {
				case 'LT':
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 'EQ':
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === 'RBNode_elm_builtin') && (_v0.a.$ === 'Red')) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) {
			var left = dict.d;
			var $temp$dict = left;
			dict = $temp$dict;
			continue getMin;
		} else {
			return dict;
		}
	}
};
var $elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) && (dict.e.$ === 'RBNode_elm_builtin')) {
		if ((dict.e.d.$ === 'RBNode_elm_builtin') && (dict.e.d.a.$ === 'Red')) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var lLeft = _v1.d;
			var lRight = _v1.e;
			var _v2 = dict.e;
			var rClr = _v2.a;
			var rK = _v2.b;
			var rV = _v2.c;
			var rLeft = _v2.d;
			var _v3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _v2.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				$elm$core$Dict$Red,
				rlK,
				rlV,
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					rlL),
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v4 = dict.d;
			var lClr = _v4.a;
			var lK = _v4.b;
			var lV = _v4.c;
			var lLeft = _v4.d;
			var lRight = _v4.e;
			var _v5 = dict.e;
			var rClr = _v5.a;
			var rK = _v5.b;
			var rV = _v5.c;
			var rLeft = _v5.d;
			var rRight = _v5.e;
			if (clr.$ === 'Black') {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) && (dict.e.$ === 'RBNode_elm_builtin')) {
		if ((dict.d.d.$ === 'RBNode_elm_builtin') && (dict.d.d.a.$ === 'Red')) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var _v2 = _v1.d;
			var _v3 = _v2.a;
			var llK = _v2.b;
			var llV = _v2.c;
			var llLeft = _v2.d;
			var llRight = _v2.e;
			var lRight = _v1.e;
			var _v4 = dict.e;
			var rClr = _v4.a;
			var rK = _v4.b;
			var rV = _v4.c;
			var rLeft = _v4.d;
			var rRight = _v4.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				$elm$core$Dict$Red,
				lK,
				lV,
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, llK, llV, llLeft, llRight),
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					lRight,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v5 = dict.d;
			var lClr = _v5.a;
			var lK = _v5.b;
			var lV = _v5.c;
			var lLeft = _v5.d;
			var lRight = _v5.e;
			var _v6 = dict.e;
			var rClr = _v6.a;
			var rK = _v6.b;
			var rV = _v6.c;
			var rLeft = _v6.d;
			var rRight = _v6.e;
			if (clr.$ === 'Black') {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
			var _v1 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				lK,
				lV,
				lLeft,
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, lRight, right));
		} else {
			_v2$2:
			while (true) {
				if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Black')) {
					if (right.d.$ === 'RBNode_elm_builtin') {
						if (right.d.a.$ === 'Black') {
							var _v3 = right.a;
							var _v4 = right.d;
							var _v5 = _v4.a;
							return $elm$core$Dict$moveRedRight(dict);
						} else {
							break _v2$2;
						}
					} else {
						var _v6 = right.a;
						var _v7 = right.d;
						return $elm$core$Dict$moveRedRight(dict);
					}
				} else {
					break _v2$2;
				}
			}
			return dict;
		}
	});
var $elm$core$Dict$removeMin = function (dict) {
	if ((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor.$ === 'Black') {
			if ((lLeft.$ === 'RBNode_elm_builtin') && (lLeft.a.$ === 'Red')) {
				var _v3 = lLeft.a;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					key,
					value,
					$elm$core$Dict$removeMin(left),
					right);
			} else {
				var _v4 = $elm$core$Dict$moveRedLeft(dict);
				if (_v4.$ === 'RBNode_elm_builtin') {
					var nColor = _v4.a;
					var nKey = _v4.b;
					var nValue = _v4.c;
					var nLeft = _v4.d;
					var nRight = _v4.e;
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						$elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				value,
				$elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var $elm$core$Dict$removeHelp = F2(
	function (targetKey, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Black')) {
					var _v4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === 'RBNode_elm_builtin') && (lLeft.a.$ === 'Red')) {
						var _v6 = lLeft.a;
						return A5(
							$elm$core$Dict$RBNode_elm_builtin,
							color,
							key,
							value,
							A2($elm$core$Dict$removeHelp, targetKey, left),
							right);
					} else {
						var _v7 = $elm$core$Dict$moveRedLeft(dict);
						if (_v7.$ === 'RBNode_elm_builtin') {
							var nColor = _v7.a;
							var nKey = _v7.b;
							var nValue = _v7.c;
							var nLeft = _v7.d;
							var nRight = _v7.e;
							return A5(
								$elm$core$Dict$balance,
								nColor,
								nKey,
								nValue,
								A2($elm$core$Dict$removeHelp, targetKey, nLeft),
								nRight);
						} else {
							return $elm$core$Dict$RBEmpty_elm_builtin;
						}
					}
				} else {
					return A5(
						$elm$core$Dict$RBNode_elm_builtin,
						color,
						key,
						value,
						A2($elm$core$Dict$removeHelp, targetKey, left),
						right);
				}
			} else {
				return A2(
					$elm$core$Dict$removeHelpEQGT,
					targetKey,
					A7($elm$core$Dict$removeHelpPrepEQGT, targetKey, dict, color, key, value, left, right));
			}
		}
	});
var $elm$core$Dict$removeHelpEQGT = F2(
	function (targetKey, dict) {
		if (dict.$ === 'RBNode_elm_builtin') {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _v1 = $elm$core$Dict$getMin(right);
				if (_v1.$ === 'RBNode_elm_builtin') {
					var minKey = _v1.b;
					var minValue = _v1.c;
					return A5(
						$elm$core$Dict$balance,
						color,
						minKey,
						minValue,
						left,
						$elm$core$Dict$removeMin(right));
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			} else {
				return A5(
					$elm$core$Dict$balance,
					color,
					key,
					value,
					left,
					A2($elm$core$Dict$removeHelp, targetKey, right));
			}
		} else {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		}
	});
var $elm$core$Dict$remove = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$removeHelp, key, dict);
		if ((_v0.$ === 'RBNode_elm_builtin') && (_v0.a.$ === 'Red')) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$update = F3(
	function (targetKey, alter, dictionary) {
		var _v0 = alter(
			A2($elm$core$Dict$get, targetKey, dictionary));
		if (_v0.$ === 'Just') {
			var value = _v0.a;
			return A3($elm$core$Dict$insert, targetKey, value, dictionary);
		} else {
			return A2($elm$core$Dict$remove, targetKey, dictionary);
		}
	});
var $elm$http$Http$emptyBody = _Http_emptyBody;
var $elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _v0 = f(mx);
		if (_v0.$ === 'Just') {
			var x = _v0.a;
			return A2($elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var $elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			$elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var $elm$http$Http$Header = F2(
	function (a, b) {
		return {$: 'Header', a: a, b: b};
	});
var $elm$http$Http$header = $elm$http$Http$Header;
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $author$project$Api$headers = $elm$core$List$filterMap(
	function (_v0) {
		var key = _v0.a;
		var value = _v0.b;
		return A2(
			$elm$core$Maybe$map,
			$elm$http$Http$header(key),
			value);
	});
var $elm$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (n <= 0) {
				return list;
			} else {
				if (!list.b) {
					return list;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs;
					n = $temp$n;
					list = $temp$list;
					continue drop;
				}
			}
		}
	});
var $elm$core$String$replace = F3(
	function (before, after, string) {
		return A2(
			$elm$core$String$join,
			after,
			A2($elm$core$String$split, before, string));
	});
var $author$project$Api$interpolatePath = F2(
	function (rawPath, pathParams) {
		var interpolate = F2(
			function (_v0, path) {
				var name = _v0.a;
				var value = _v0.b;
				return A3($elm$core$String$replace, '{' + (name + '}'), value, path);
			});
		return A2(
			$elm$core$List$drop,
			1,
			A2(
				$elm$core$String$split,
				'/',
				A3($elm$core$List$foldl, interpolate, rawPath, pathParams)));
	});
var $elm$http$Http$jsonBody = function (value) {
	return A2(
		_Http_pair,
		'application/json',
		A2($elm$json$Json$Encode$encode, 0, value));
};
var $elm$url$Url$Builder$QueryParameter = F2(
	function (a, b) {
		return {$: 'QueryParameter', a: a, b: b};
	});
var $elm$url$Url$percentEncode = _Url_percentEncode;
var $elm$url$Url$Builder$string = F2(
	function (key, value) {
		return A2(
			$elm$url$Url$Builder$QueryParameter,
			$elm$url$Url$percentEncode(key),
			$elm$url$Url$percentEncode(value));
	});
var $author$project$Api$queries = $elm$core$List$filterMap(
	function (_v0) {
		var key = _v0.a;
		var value = _v0.b;
		return A2(
			$elm$core$Maybe$map,
			$elm$url$Url$Builder$string(key),
			value);
	});
var $author$project$Api$request = F7(
	function (method, path, pathParams, queryParams, headerParams, body, decoder) {
		return $author$project$Api$Request(
			{
				basePath: 'http://edu.lcme/api',
				body: A2(
					$elm$core$Maybe$withDefault,
					$elm$http$Http$emptyBody,
					A2($elm$core$Maybe$map, $elm$http$Http$jsonBody, body)),
				decoder: decoder,
				headers: $author$project$Api$headers(headerParams),
				method: method,
				pathParams: A2($author$project$Api$interpolatePath, path, pathParams),
				queryParams: $author$project$Api$queries(queryParams),
				timeout: $elm$core$Maybe$Nothing,
				tracker: $elm$core$Maybe$Nothing
			});
	});
var $author$project$Api$Request$Course$courseList = A7(
	$author$project$Api$request,
	'GET',
	'/course/',
	_List_Nil,
	_List_Nil,
	_List_Nil,
	$elm$core$Maybe$Nothing,
	$elm$json$Json$Decode$list($author$project$Api$Data$courseReadDecoder));
var $author$project$Util$httpErrorToString = function (error) {
	switch (error.$) {
		case 'BadUrl':
			var url = error.a;
			return 'Некорректный адрес: ' + url;
		case 'Timeout':
			return 'Таймаут';
		case 'NetworkError':
			return 'Сетевая ошибка';
		case 'BadStatus':
			var code = error.a;
			return 'Код ошибки: ' + $elm$core$String$fromInt(code);
		default:
			var s = error.a;
			return 'Некорректный формат данных: ' + s;
	}
};
var $elm$url$Url$Builder$toQueryPair = function (_v0) {
	var key = _v0.a;
	var value = _v0.b;
	return key + ('=' + value);
};
var $elm$url$Url$Builder$toQuery = function (parameters) {
	if (!parameters.b) {
		return '';
	} else {
		return '?' + A2(
			$elm$core$String$join,
			'&',
			A2($elm$core$List$map, $elm$url$Url$Builder$toQueryPair, parameters));
	}
};
var $elm$url$Url$Builder$crossOrigin = F3(
	function (prePath, pathSegments, parameters) {
		return prePath + ('/' + (A2($elm$core$String$join, '/', pathSegments) + $elm$url$Url$Builder$toQuery(parameters)));
	});
var $elm$http$Http$BadStatus = function (a) {
	return {$: 'BadStatus', a: a};
};
var $elm$http$Http$BadUrl = function (a) {
	return {$: 'BadUrl', a: a};
};
var $elm$http$Http$NetworkError = {$: 'NetworkError'};
var $elm$http$Http$Timeout = {$: 'Timeout'};
var $elm$http$Http$BadBody = function (a) {
	return {$: 'BadBody', a: a};
};
var $elm$json$Json$Decode$decodeString = _Json_runOnString;
var $author$project$Api$decodeBody = F2(
	function (decoder, body) {
		var _v0 = A2($elm$json$Json$Decode$decodeString, decoder, body);
		if (_v0.$ === 'Ok') {
			var value = _v0.a;
			return $elm$core$Result$Ok(value);
		} else {
			var err = _v0.a;
			return $elm$core$Result$Err(
				$elm$http$Http$BadBody(
					$elm$json$Json$Decode$errorToString(err)));
		}
	});
var $author$project$Api$decodeResponse = F2(
	function (decoder, response) {
		switch (response.$) {
			case 'BadUrl_':
				var url = response.a;
				return $elm$core$Result$Err(
					$elm$http$Http$BadUrl(url));
			case 'Timeout_':
				return $elm$core$Result$Err($elm$http$Http$Timeout);
			case 'NetworkError_':
				return $elm$core$Result$Err($elm$http$Http$NetworkError);
			case 'BadStatus_':
				var metadata = response.a;
				return $elm$core$Result$Err(
					$elm$http$Http$BadStatus(metadata.statusCode));
			default:
				var body = response.b;
				if ($elm$core$String$isEmpty(body)) {
					var _v1 = A2($elm$json$Json$Decode$decodeString, decoder, '{}');
					if (_v1.$ === 'Ok') {
						var value = _v1.a;
						return $elm$core$Result$Ok(value);
					} else {
						return A2($author$project$Api$decodeBody, decoder, body);
					}
				} else {
					return A2($author$project$Api$decodeBody, decoder, body);
				}
		}
	});
var $elm$http$Http$stringResolver = A2(_Http_expect, '', $elm$core$Basics$identity);
var $author$project$Api$jsonResolver = function (decoder) {
	return $elm$http$Http$stringResolver(
		$author$project$Api$decodeResponse(decoder));
};
var $elm$core$Task$fail = _Scheduler_fail;
var $elm$http$Http$resultToTask = function (result) {
	if (result.$ === 'Ok') {
		var a = result.a;
		return $elm$core$Task$succeed(a);
	} else {
		var x = result.a;
		return $elm$core$Task$fail(x);
	}
};
var $elm$http$Http$task = function (r) {
	return A3(
		_Http_toTask,
		_Utils_Tuple0,
		$elm$http$Http$resultToTask,
		{allowCookiesFromOtherDomains: false, body: r.body, expect: r.resolver, headers: r.headers, method: r.method, timeout: r.timeout, tracker: $elm$core$Maybe$Nothing, url: r.url});
};
var $author$project$Api$task = function (_v0) {
	var req = _v0.a;
	return $elm$http$Http$task(
		{
			body: req.body,
			headers: req.headers,
			method: req.method,
			resolver: $author$project$Api$jsonResolver(req.decoder),
			timeout: req.timeout,
			url: A3($elm$url$Url$Builder$crossOrigin, req.basePath, req.pathParams, req.queryParams)
		});
};
var $elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var $elm$core$Task$onError = _Scheduler_onError;
var $elm$core$Task$attempt = F2(
	function (resultToMessage, task) {
		return $elm$core$Task$command(
			$elm$core$Task$Perform(
				A2(
					$elm$core$Task$onError,
					A2(
						$elm$core$Basics$composeL,
						A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage),
						$elm$core$Result$Err),
					A2(
						$elm$core$Task$andThen,
						A2(
							$elm$core$Basics$composeL,
							A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage),
							$elm$core$Result$Ok),
						task))));
	});
var $author$project$Util$task_to_cmd = F2(
	function (on_err, on_success) {
		var on_result = function (r) {
			if (r.$ === 'Ok') {
				var x = r.a;
				return on_success(x);
			} else {
				var x = r.a;
				return on_err(x);
			}
		};
		return $elm$core$Task$attempt(on_result);
	});
var $author$project$Api$withToken = F2(
	function (token, _v0) {
		var req = _v0.a;
		if (token.$ === 'Just') {
			var t = token.a;
			return $author$project$Api$Request(
				_Utils_update(
					req,
					{
						headers: A2(
							$elm$core$List$cons,
							A2($elm$http$Http$header, 'Authorization', 'Token ' + t),
							req.headers)
					}));
		} else {
			return $author$project$Api$Request(req);
		}
	});
var $author$project$Page$CourseListPage$doFetchCourses = function (token) {
	return A3(
		$author$project$Util$task_to_cmd,
		A2($elm$core$Basics$composeR, $author$project$Util$httpErrorToString, $author$project$Page$CourseListPage$CourseListFetchFailed),
		$author$project$Page$CourseListPage$GotCourses,
		$author$project$Api$task(
			A2(
				$author$project$Api$withToken,
				$elm$core$Maybe$Just(token),
				$author$project$Api$Request$Course$courseList)));
};
var $author$project$Page$CourseListPage$init = function (token) {
	return _Utils_Tuple2(
		{group_by: $author$project$Page$CourseListPage$GroupByClass, state: $author$project$Page$CourseListPage$Loading, token: token},
		$author$project$Page$CourseListPage$doFetchCourses(token));
};
var $author$project$Page$CoursePage$Fetching = function (a) {
	return {$: 'Fetching', a: a};
};
var $author$project$Page$CoursePage$MsgFetch = function (a) {
	return {$: 'MsgFetch', a: a};
};
var $author$project$Page$CoursePage$ResActivities = function (a) {
	return {$: 'ResActivities', a: a};
};
var $author$project$Component$MultiTask$Running = {$: 'Running'};
var $author$project$Component$MultiTask$TaskCompleted = F2(
	function (a, b) {
		return {$: 'TaskCompleted', a: a, b: b};
	});
var $author$project$Component$MultiTask$TaskFailed = F2(
	function (a, b) {
		return {$: 'TaskFailed', a: a, b: b};
	});
var $author$project$Component$MultiTask$doFetch = F2(
	function (idx, task) {
		return A3(
			$author$project$Util$task_to_cmd,
			$author$project$Component$MultiTask$TaskFailed(idx),
			$author$project$Component$MultiTask$TaskCompleted(idx),
			task);
	});
var $elm$core$Array$fromListHelp = F3(
	function (list, nodeList, nodeListSize) {
		fromListHelp:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, list);
			var jsArray = _v0.a;
			var remainingItems = _v0.b;
			if (_Utils_cmp(
				$elm$core$Elm$JsArray$length(jsArray),
				$elm$core$Array$branchFactor) < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					true,
					{nodeList: nodeList, nodeListSize: nodeListSize, tail: jsArray});
			} else {
				var $temp$list = remainingItems,
					$temp$nodeList = A2(
					$elm$core$List$cons,
					$elm$core$Array$Leaf(jsArray),
					nodeList),
					$temp$nodeListSize = nodeListSize + 1;
				list = $temp$list;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue fromListHelp;
			}
		}
	});
var $elm$core$Array$fromList = function (list) {
	if (!list.b) {
		return $elm$core$Array$empty;
	} else {
		return A3($elm$core$Array$fromListHelp, list, _List_Nil, 0);
	}
};
var $elm$core$Array$length = function (_v0) {
	var len = _v0.a;
	return len;
};
var $elm$core$Elm$JsArray$map = _JsArray_map;
var $elm$core$Array$map = F2(
	function (func, _v0) {
		var len = _v0.a;
		var startShift = _v0.b;
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = function (node) {
			if (node.$ === 'SubTree') {
				var subTree = node.a;
				return $elm$core$Array$SubTree(
					A2($elm$core$Elm$JsArray$map, helper, subTree));
			} else {
				var values = node.a;
				return $elm$core$Array$Leaf(
					A2($elm$core$Elm$JsArray$map, func, values));
			}
		};
		return A4(
			$elm$core$Array$Array_elm_builtin,
			len,
			startShift,
			A2($elm$core$Elm$JsArray$map, helper, tree),
			A2($elm$core$Elm$JsArray$map, func, tail));
	});
var $author$project$Component$MultiTask$init = function (tasks) {
	var states = A2(
		$elm$core$Array$map,
		function (_v1) {
			var t = _v1.a;
			var label = _v1.b;
			return _Utils_Tuple3(label, $author$project$Component$MultiTask$Running, t);
		},
		$elm$core$Array$fromList(tasks));
	return _Utils_Tuple2(
		{
			task_states: states,
			tasks_left: $elm$core$Array$length(states)
		},
		$elm$core$Platform$Cmd$batch(
			A2(
				$elm$core$List$indexedMap,
				F2(
					function (i, _v0) {
						var t = _v0.a;
						return A2($author$project$Component$MultiTask$doFetch, i, t);
					}),
				tasks)));
};
var $elm$core$Platform$Cmd$map = _Platform_map;
var $author$project$Page$CoursePage$init = F2(
	function (token, id) {
		var _v0 = $author$project$Component$MultiTask$init(
			_List_fromArray(
				[
					_Utils_Tuple2(
					$elm$core$Task$succeed(
						$author$project$Page$CoursePage$ResActivities(_List_Nil)),
					'Получаем активности'),
					_Utils_Tuple2(
					$elm$core$Task$fail($elm$http$Http$Timeout),
					'Получение чего-то')
				]));
		var m = _v0.a;
		var c = _v0.b;
		return _Utils_Tuple2(
			{
				state: $author$project$Page$CoursePage$Fetching(m),
				token: token
			},
			A2($elm$core$Platform$Cmd$map, $author$project$Page$CoursePage$MsgFetch, c));
	});
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $author$project$Page$DefaultLayout$init = function (user) {
	return _Utils_Tuple2(
		{show_sidebar: false, user: user},
		$elm$core$Platform$Cmd$none);
};
var $author$project$Page$Login$CheckingStored = {$: 'CheckingStored'};
var $author$project$Page$Login$None = {$: 'None'};
var $author$project$Page$Login$CheckSessionFailed = function (a) {
	return {$: 'CheckSessionFailed', a: a};
};
var $author$project$Page$Login$LoginCompleted = function (a) {
	return {$: 'LoginCompleted', a: a};
};
var $author$project$Page$Login$ShowLogin = {$: 'ShowLogin'};
var $elm$core$Task$mapError = F2(
	function (convert, task) {
		return A2(
			$elm$core$Task$onError,
			A2($elm$core$Basics$composeL, $elm$core$Task$fail, convert),
			task);
	});
var $elm$time$Time$Name = function (a) {
	return {$: 'Name', a: a};
};
var $elm$time$Time$Offset = function (a) {
	return {$: 'Offset', a: a};
};
var $elm$time$Time$Zone = F2(
	function (a, b) {
		return {$: 'Zone', a: a, b: b};
	});
var $elm$time$Time$customZone = $elm$time$Time$Zone;
var $elm$time$Time$Posix = function (a) {
	return {$: 'Posix', a: a};
};
var $elm$time$Time$millisToPosix = $elm$time$Time$Posix;
var $elm$time$Time$now = _Time_now($elm$time$Time$millisToPosix);
var $author$project$Api$Data$User = function (id) {
	return function (lastLogin) {
		return function (isSuperuser) {
			return function (username) {
				return function (firstName) {
					return function (lastName) {
						return function (email) {
							return function (isStaff) {
								return function (isActive) {
									return function (dateJoined) {
										return function (middleName) {
											return function (birthDate) {
												return function (avatar) {
													return function (groups) {
														return function (userPermissions) {
															return function (children) {
																return {avatar: avatar, birthDate: birthDate, children: children, dateJoined: dateJoined, email: email, firstName: firstName, groups: groups, id: id, isActive: isActive, isStaff: isStaff, isSuperuser: isSuperuser, lastLogin: lastLogin, lastName: lastName, middleName: middleName, userPermissions: userPermissions, username: username};
															};
														};
													};
												};
											};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $elm$json$Json$Decode$bool = _Json_decodeBool;
var $elm$parser$Parser$Advanced$Bad = F2(
	function (a, b) {
		return {$: 'Bad', a: a, b: b};
	});
var $elm$parser$Parser$Advanced$Good = F3(
	function (a, b, c) {
		return {$: 'Good', a: a, b: b, c: c};
	});
var $elm$parser$Parser$Advanced$Parser = function (a) {
	return {$: 'Parser', a: a};
};
var $elm$parser$Parser$Advanced$andThen = F2(
	function (callback, _v0) {
		var parseA = _v0.a;
		return $elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _v1 = parseA(s0);
				if (_v1.$ === 'Bad') {
					var p = _v1.a;
					var x = _v1.b;
					return A2($elm$parser$Parser$Advanced$Bad, p, x);
				} else {
					var p1 = _v1.a;
					var a = _v1.b;
					var s1 = _v1.c;
					var _v2 = callback(a);
					var parseB = _v2.a;
					var _v3 = parseB(s1);
					if (_v3.$ === 'Bad') {
						var p2 = _v3.a;
						var x = _v3.b;
						return A2($elm$parser$Parser$Advanced$Bad, p1 || p2, x);
					} else {
						var p2 = _v3.a;
						var b = _v3.b;
						var s2 = _v3.c;
						return A3($elm$parser$Parser$Advanced$Good, p1 || p2, b, s2);
					}
				}
			});
	});
var $elm$parser$Parser$andThen = $elm$parser$Parser$Advanced$andThen;
var $elm$parser$Parser$ExpectingEnd = {$: 'ExpectingEnd'};
var $elm$parser$Parser$Advanced$AddRight = F2(
	function (a, b) {
		return {$: 'AddRight', a: a, b: b};
	});
var $elm$parser$Parser$Advanced$DeadEnd = F4(
	function (row, col, problem, contextStack) {
		return {col: col, contextStack: contextStack, problem: problem, row: row};
	});
var $elm$parser$Parser$Advanced$Empty = {$: 'Empty'};
var $elm$parser$Parser$Advanced$fromState = F2(
	function (s, x) {
		return A2(
			$elm$parser$Parser$Advanced$AddRight,
			$elm$parser$Parser$Advanced$Empty,
			A4($elm$parser$Parser$Advanced$DeadEnd, s.row, s.col, x, s.context));
	});
var $elm$parser$Parser$Advanced$end = function (x) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return _Utils_eq(
				$elm$core$String$length(s.src),
				s.offset) ? A3($elm$parser$Parser$Advanced$Good, false, _Utils_Tuple0, s) : A2(
				$elm$parser$Parser$Advanced$Bad,
				false,
				A2($elm$parser$Parser$Advanced$fromState, s, x));
		});
};
var $elm$parser$Parser$end = $elm$parser$Parser$Advanced$end($elm$parser$Parser$ExpectingEnd);
var $elm$parser$Parser$Advanced$isSubChar = _Parser_isSubChar;
var $elm$core$Basics$negate = function (n) {
	return -n;
};
var $elm$parser$Parser$Advanced$chompWhileHelp = F5(
	function (isGood, offset, row, col, s0) {
		chompWhileHelp:
		while (true) {
			var newOffset = A3($elm$parser$Parser$Advanced$isSubChar, isGood, offset, s0.src);
			if (_Utils_eq(newOffset, -1)) {
				return A3(
					$elm$parser$Parser$Advanced$Good,
					_Utils_cmp(s0.offset, offset) < 0,
					_Utils_Tuple0,
					{col: col, context: s0.context, indent: s0.indent, offset: offset, row: row, src: s0.src});
			} else {
				if (_Utils_eq(newOffset, -2)) {
					var $temp$isGood = isGood,
						$temp$offset = offset + 1,
						$temp$row = row + 1,
						$temp$col = 1,
						$temp$s0 = s0;
					isGood = $temp$isGood;
					offset = $temp$offset;
					row = $temp$row;
					col = $temp$col;
					s0 = $temp$s0;
					continue chompWhileHelp;
				} else {
					var $temp$isGood = isGood,
						$temp$offset = newOffset,
						$temp$row = row,
						$temp$col = col + 1,
						$temp$s0 = s0;
					isGood = $temp$isGood;
					offset = $temp$offset;
					row = $temp$row;
					col = $temp$col;
					s0 = $temp$s0;
					continue chompWhileHelp;
				}
			}
		}
	});
var $elm$parser$Parser$Advanced$chompWhile = function (isGood) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A5($elm$parser$Parser$Advanced$chompWhileHelp, isGood, s.offset, s.row, s.col, s);
		});
};
var $elm$parser$Parser$chompWhile = $elm$parser$Parser$Advanced$chompWhile;
var $elm$core$Basics$always = F2(
	function (a, _v0) {
		return a;
	});
var $elm$parser$Parser$Advanced$mapChompedString = F2(
	function (func, _v0) {
		var parse = _v0.a;
		return $elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _v1 = parse(s0);
				if (_v1.$ === 'Bad') {
					var p = _v1.a;
					var x = _v1.b;
					return A2($elm$parser$Parser$Advanced$Bad, p, x);
				} else {
					var p = _v1.a;
					var a = _v1.b;
					var s1 = _v1.c;
					return A3(
						$elm$parser$Parser$Advanced$Good,
						p,
						A2(
							func,
							A3($elm$core$String$slice, s0.offset, s1.offset, s0.src),
							a),
						s1);
				}
			});
	});
var $elm$parser$Parser$Advanced$getChompedString = function (parser) {
	return A2($elm$parser$Parser$Advanced$mapChompedString, $elm$core$Basics$always, parser);
};
var $elm$parser$Parser$getChompedString = $elm$parser$Parser$Advanced$getChompedString;
var $elm$parser$Parser$Problem = function (a) {
	return {$: 'Problem', a: a};
};
var $elm$parser$Parser$Advanced$problem = function (x) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A2(
				$elm$parser$Parser$Advanced$Bad,
				false,
				A2($elm$parser$Parser$Advanced$fromState, s, x));
		});
};
var $elm$parser$Parser$problem = function (msg) {
	return $elm$parser$Parser$Advanced$problem(
		$elm$parser$Parser$Problem(msg));
};
var $elm$core$Basics$round = _Basics_round;
var $elm$parser$Parser$Advanced$succeed = function (a) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A3($elm$parser$Parser$Advanced$Good, false, a, s);
		});
};
var $elm$parser$Parser$succeed = $elm$parser$Parser$Advanced$succeed;
var $elm$core$String$toFloat = _String_toFloat;
var $rtfeldman$elm_iso8601_date_strings$Iso8601$fractionsOfASecondInMs = A2(
	$elm$parser$Parser$andThen,
	function (str) {
		if ($elm$core$String$length(str) <= 9) {
			var _v0 = $elm$core$String$toFloat('0.' + str);
			if (_v0.$ === 'Just') {
				var floatVal = _v0.a;
				return $elm$parser$Parser$succeed(
					$elm$core$Basics$round(floatVal * 1000));
			} else {
				return $elm$parser$Parser$problem('Invalid float: \"' + (str + '\"'));
			}
		} else {
			return $elm$parser$Parser$problem(
				'Expected at most 9 digits, but got ' + $elm$core$String$fromInt(
					$elm$core$String$length(str)));
		}
	},
	$elm$parser$Parser$getChompedString(
		$elm$parser$Parser$chompWhile($elm$core$Char$isDigit)));
var $rtfeldman$elm_iso8601_date_strings$Iso8601$fromParts = F6(
	function (monthYearDayMs, hour, minute, second, ms, utcOffsetMinutes) {
		return $elm$time$Time$millisToPosix((((monthYearDayMs + (((hour * 60) * 60) * 1000)) + (((minute - utcOffsetMinutes) * 60) * 1000)) + (second * 1000)) + ms);
	});
var $elm$parser$Parser$Advanced$map2 = F3(
	function (func, _v0, _v1) {
		var parseA = _v0.a;
		var parseB = _v1.a;
		return $elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _v2 = parseA(s0);
				if (_v2.$ === 'Bad') {
					var p = _v2.a;
					var x = _v2.b;
					return A2($elm$parser$Parser$Advanced$Bad, p, x);
				} else {
					var p1 = _v2.a;
					var a = _v2.b;
					var s1 = _v2.c;
					var _v3 = parseB(s1);
					if (_v3.$ === 'Bad') {
						var p2 = _v3.a;
						var x = _v3.b;
						return A2($elm$parser$Parser$Advanced$Bad, p1 || p2, x);
					} else {
						var p2 = _v3.a;
						var b = _v3.b;
						var s2 = _v3.c;
						return A3(
							$elm$parser$Parser$Advanced$Good,
							p1 || p2,
							A2(func, a, b),
							s2);
					}
				}
			});
	});
var $elm$parser$Parser$Advanced$ignorer = F2(
	function (keepParser, ignoreParser) {
		return A3($elm$parser$Parser$Advanced$map2, $elm$core$Basics$always, keepParser, ignoreParser);
	});
var $elm$parser$Parser$ignorer = $elm$parser$Parser$Advanced$ignorer;
var $elm$parser$Parser$Advanced$keeper = F2(
	function (parseFunc, parseArg) {
		return A3($elm$parser$Parser$Advanced$map2, $elm$core$Basics$apL, parseFunc, parseArg);
	});
var $elm$parser$Parser$keeper = $elm$parser$Parser$Advanced$keeper;
var $elm$parser$Parser$Advanced$Append = F2(
	function (a, b) {
		return {$: 'Append', a: a, b: b};
	});
var $elm$parser$Parser$Advanced$oneOfHelp = F3(
	function (s0, bag, parsers) {
		oneOfHelp:
		while (true) {
			if (!parsers.b) {
				return A2($elm$parser$Parser$Advanced$Bad, false, bag);
			} else {
				var parse = parsers.a.a;
				var remainingParsers = parsers.b;
				var _v1 = parse(s0);
				if (_v1.$ === 'Good') {
					var step = _v1;
					return step;
				} else {
					var step = _v1;
					var p = step.a;
					var x = step.b;
					if (p) {
						return step;
					} else {
						var $temp$s0 = s0,
							$temp$bag = A2($elm$parser$Parser$Advanced$Append, bag, x),
							$temp$parsers = remainingParsers;
						s0 = $temp$s0;
						bag = $temp$bag;
						parsers = $temp$parsers;
						continue oneOfHelp;
					}
				}
			}
		}
	});
var $elm$parser$Parser$Advanced$oneOf = function (parsers) {
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			return A3($elm$parser$Parser$Advanced$oneOfHelp, s, $elm$parser$Parser$Advanced$Empty, parsers);
		});
};
var $elm$parser$Parser$oneOf = $elm$parser$Parser$Advanced$oneOf;
var $elm$parser$Parser$Done = function (a) {
	return {$: 'Done', a: a};
};
var $elm$parser$Parser$Loop = function (a) {
	return {$: 'Loop', a: a};
};
var $elm$core$String$append = _String_append;
var $elm$parser$Parser$UnexpectedChar = {$: 'UnexpectedChar'};
var $elm$parser$Parser$Advanced$chompIf = F2(
	function (isGood, expecting) {
		return $elm$parser$Parser$Advanced$Parser(
			function (s) {
				var newOffset = A3($elm$parser$Parser$Advanced$isSubChar, isGood, s.offset, s.src);
				return _Utils_eq(newOffset, -1) ? A2(
					$elm$parser$Parser$Advanced$Bad,
					false,
					A2($elm$parser$Parser$Advanced$fromState, s, expecting)) : (_Utils_eq(newOffset, -2) ? A3(
					$elm$parser$Parser$Advanced$Good,
					true,
					_Utils_Tuple0,
					{col: 1, context: s.context, indent: s.indent, offset: s.offset + 1, row: s.row + 1, src: s.src}) : A3(
					$elm$parser$Parser$Advanced$Good,
					true,
					_Utils_Tuple0,
					{col: s.col + 1, context: s.context, indent: s.indent, offset: newOffset, row: s.row, src: s.src}));
			});
	});
var $elm$parser$Parser$chompIf = function (isGood) {
	return A2($elm$parser$Parser$Advanced$chompIf, isGood, $elm$parser$Parser$UnexpectedChar);
};
var $elm$parser$Parser$Advanced$loopHelp = F4(
	function (p, state, callback, s0) {
		loopHelp:
		while (true) {
			var _v0 = callback(state);
			var parse = _v0.a;
			var _v1 = parse(s0);
			if (_v1.$ === 'Good') {
				var p1 = _v1.a;
				var step = _v1.b;
				var s1 = _v1.c;
				if (step.$ === 'Loop') {
					var newState = step.a;
					var $temp$p = p || p1,
						$temp$state = newState,
						$temp$callback = callback,
						$temp$s0 = s1;
					p = $temp$p;
					state = $temp$state;
					callback = $temp$callback;
					s0 = $temp$s0;
					continue loopHelp;
				} else {
					var result = step.a;
					return A3($elm$parser$Parser$Advanced$Good, p || p1, result, s1);
				}
			} else {
				var p1 = _v1.a;
				var x = _v1.b;
				return A2($elm$parser$Parser$Advanced$Bad, p || p1, x);
			}
		}
	});
var $elm$parser$Parser$Advanced$loop = F2(
	function (state, callback) {
		return $elm$parser$Parser$Advanced$Parser(
			function (s) {
				return A4($elm$parser$Parser$Advanced$loopHelp, false, state, callback, s);
			});
	});
var $elm$parser$Parser$Advanced$map = F2(
	function (func, _v0) {
		var parse = _v0.a;
		return $elm$parser$Parser$Advanced$Parser(
			function (s0) {
				var _v1 = parse(s0);
				if (_v1.$ === 'Good') {
					var p = _v1.a;
					var a = _v1.b;
					var s1 = _v1.c;
					return A3(
						$elm$parser$Parser$Advanced$Good,
						p,
						func(a),
						s1);
				} else {
					var p = _v1.a;
					var x = _v1.b;
					return A2($elm$parser$Parser$Advanced$Bad, p, x);
				}
			});
	});
var $elm$parser$Parser$map = $elm$parser$Parser$Advanced$map;
var $elm$parser$Parser$Advanced$Done = function (a) {
	return {$: 'Done', a: a};
};
var $elm$parser$Parser$Advanced$Loop = function (a) {
	return {$: 'Loop', a: a};
};
var $elm$parser$Parser$toAdvancedStep = function (step) {
	if (step.$ === 'Loop') {
		var s = step.a;
		return $elm$parser$Parser$Advanced$Loop(s);
	} else {
		var a = step.a;
		return $elm$parser$Parser$Advanced$Done(a);
	}
};
var $elm$parser$Parser$loop = F2(
	function (state, callback) {
		return A2(
			$elm$parser$Parser$Advanced$loop,
			state,
			function (s) {
				return A2(
					$elm$parser$Parser$map,
					$elm$parser$Parser$toAdvancedStep,
					callback(s));
			});
	});
var $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt = function (quantity) {
	var helper = function (str) {
		if (_Utils_eq(
			$elm$core$String$length(str),
			quantity)) {
			var _v0 = $elm$core$String$toInt(str);
			if (_v0.$ === 'Just') {
				var intVal = _v0.a;
				return A2(
					$elm$parser$Parser$map,
					$elm$parser$Parser$Done,
					$elm$parser$Parser$succeed(intVal));
			} else {
				return $elm$parser$Parser$problem('Invalid integer: \"' + (str + '\"'));
			}
		} else {
			return A2(
				$elm$parser$Parser$map,
				function (nextChar) {
					return $elm$parser$Parser$Loop(
						A2($elm$core$String$append, str, nextChar));
				},
				$elm$parser$Parser$getChompedString(
					$elm$parser$Parser$chompIf($elm$core$Char$isDigit)));
		}
	};
	return A2($elm$parser$Parser$loop, '', helper);
};
var $elm$parser$Parser$ExpectingSymbol = function (a) {
	return {$: 'ExpectingSymbol', a: a};
};
var $elm$parser$Parser$Advanced$Token = F2(
	function (a, b) {
		return {$: 'Token', a: a, b: b};
	});
var $elm$parser$Parser$Advanced$isSubString = _Parser_isSubString;
var $elm$core$Basics$not = _Basics_not;
var $elm$parser$Parser$Advanced$token = function (_v0) {
	var str = _v0.a;
	var expecting = _v0.b;
	var progress = !$elm$core$String$isEmpty(str);
	return $elm$parser$Parser$Advanced$Parser(
		function (s) {
			var _v1 = A5($elm$parser$Parser$Advanced$isSubString, str, s.offset, s.row, s.col, s.src);
			var newOffset = _v1.a;
			var newRow = _v1.b;
			var newCol = _v1.c;
			return _Utils_eq(newOffset, -1) ? A2(
				$elm$parser$Parser$Advanced$Bad,
				false,
				A2($elm$parser$Parser$Advanced$fromState, s, expecting)) : A3(
				$elm$parser$Parser$Advanced$Good,
				progress,
				_Utils_Tuple0,
				{col: newCol, context: s.context, indent: s.indent, offset: newOffset, row: newRow, src: s.src});
		});
};
var $elm$parser$Parser$Advanced$symbol = $elm$parser$Parser$Advanced$token;
var $elm$parser$Parser$symbol = function (str) {
	return $elm$parser$Parser$Advanced$symbol(
		A2(
			$elm$parser$Parser$Advanced$Token,
			str,
			$elm$parser$Parser$ExpectingSymbol(str)));
};
var $rtfeldman$elm_iso8601_date_strings$Iso8601$epochYear = 1970;
var $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay = function (day) {
	return $elm$parser$Parser$problem(
		'Invalid day: ' + $elm$core$String$fromInt(day));
};
var $elm$core$Basics$modBy = _Basics_modBy;
var $elm$core$Basics$neq = _Utils_notEqual;
var $rtfeldman$elm_iso8601_date_strings$Iso8601$isLeapYear = function (year) {
	return (!A2($elm$core$Basics$modBy, 4, year)) && ((!(!A2($elm$core$Basics$modBy, 100, year))) || (!A2($elm$core$Basics$modBy, 400, year)));
};
var $rtfeldman$elm_iso8601_date_strings$Iso8601$leapYearsBefore = function (y1) {
	var y = y1 - 1;
	return (((y / 4) | 0) - ((y / 100) | 0)) + ((y / 400) | 0);
};
var $rtfeldman$elm_iso8601_date_strings$Iso8601$msPerDay = 86400000;
var $rtfeldman$elm_iso8601_date_strings$Iso8601$msPerYear = 31536000000;
var $rtfeldman$elm_iso8601_date_strings$Iso8601$yearMonthDay = function (_v0) {
	var year = _v0.a;
	var month = _v0.b;
	var dayInMonth = _v0.c;
	if (dayInMonth < 0) {
		return $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth);
	} else {
		var succeedWith = function (extraMs) {
			var yearMs = $rtfeldman$elm_iso8601_date_strings$Iso8601$msPerYear * (year - $rtfeldman$elm_iso8601_date_strings$Iso8601$epochYear);
			var days = ((month < 3) || (!$rtfeldman$elm_iso8601_date_strings$Iso8601$isLeapYear(year))) ? (dayInMonth - 1) : dayInMonth;
			var dayMs = $rtfeldman$elm_iso8601_date_strings$Iso8601$msPerDay * (days + ($rtfeldman$elm_iso8601_date_strings$Iso8601$leapYearsBefore(year) - $rtfeldman$elm_iso8601_date_strings$Iso8601$leapYearsBefore($rtfeldman$elm_iso8601_date_strings$Iso8601$epochYear)));
			return $elm$parser$Parser$succeed((extraMs + yearMs) + dayMs);
		};
		switch (month) {
			case 1:
				return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(0);
			case 2:
				return ((dayInMonth > 29) || ((dayInMonth === 29) && (!$rtfeldman$elm_iso8601_date_strings$Iso8601$isLeapYear(year)))) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(2678400000);
			case 3:
				return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(5097600000);
			case 4:
				return (dayInMonth > 30) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(7776000000);
			case 5:
				return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(10368000000);
			case 6:
				return (dayInMonth > 30) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(13046400000);
			case 7:
				return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(15638400000);
			case 8:
				return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(18316800000);
			case 9:
				return (dayInMonth > 30) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(20995200000);
			case 10:
				return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(23587200000);
			case 11:
				return (dayInMonth > 30) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(26265600000);
			case 12:
				return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(28857600000);
			default:
				return $elm$parser$Parser$problem(
					'Invalid month: \"' + ($elm$core$String$fromInt(month) + '\"'));
		}
	}
};
var $rtfeldman$elm_iso8601_date_strings$Iso8601$monthYearDayInMs = A2(
	$elm$parser$Parser$andThen,
	$rtfeldman$elm_iso8601_date_strings$Iso8601$yearMonthDay,
	A2(
		$elm$parser$Parser$keeper,
		A2(
			$elm$parser$Parser$keeper,
			A2(
				$elm$parser$Parser$keeper,
				$elm$parser$Parser$succeed(
					F3(
						function (year, month, day) {
							return _Utils_Tuple3(year, month, day);
						})),
				$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(4)),
			$elm$parser$Parser$oneOf(
				_List_fromArray(
					[
						A2(
						$elm$parser$Parser$keeper,
						A2(
							$elm$parser$Parser$ignorer,
							$elm$parser$Parser$succeed($elm$core$Basics$identity),
							$elm$parser$Parser$symbol('-')),
						$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
						$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)
					]))),
		$elm$parser$Parser$oneOf(
			_List_fromArray(
				[
					A2(
					$elm$parser$Parser$keeper,
					A2(
						$elm$parser$Parser$ignorer,
						$elm$parser$Parser$succeed($elm$core$Basics$identity),
						$elm$parser$Parser$symbol('-')),
					$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
					$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)
				]))));
var $rtfeldman$elm_iso8601_date_strings$Iso8601$utcOffsetInMinutes = function () {
	var utcOffsetMinutesFromParts = F3(
		function (multiplier, hours, minutes) {
			return (multiplier * (hours * 60)) + minutes;
		});
	return A2(
		$elm$parser$Parser$keeper,
		$elm$parser$Parser$succeed($elm$core$Basics$identity),
		$elm$parser$Parser$oneOf(
			_List_fromArray(
				[
					A2(
					$elm$parser$Parser$map,
					function (_v0) {
						return 0;
					},
					$elm$parser$Parser$symbol('Z')),
					A2(
					$elm$parser$Parser$keeper,
					A2(
						$elm$parser$Parser$keeper,
						A2(
							$elm$parser$Parser$keeper,
							$elm$parser$Parser$succeed(utcOffsetMinutesFromParts),
							$elm$parser$Parser$oneOf(
								_List_fromArray(
									[
										A2(
										$elm$parser$Parser$map,
										function (_v1) {
											return 1;
										},
										$elm$parser$Parser$symbol('+')),
										A2(
										$elm$parser$Parser$map,
										function (_v2) {
											return -1;
										},
										$elm$parser$Parser$symbol('-'))
									]))),
						$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
					$elm$parser$Parser$oneOf(
						_List_fromArray(
							[
								A2(
								$elm$parser$Parser$keeper,
								A2(
									$elm$parser$Parser$ignorer,
									$elm$parser$Parser$succeed($elm$core$Basics$identity),
									$elm$parser$Parser$symbol(':')),
								$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
								$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2),
								$elm$parser$Parser$succeed(0)
							]))),
					A2(
					$elm$parser$Parser$ignorer,
					$elm$parser$Parser$succeed(0),
					$elm$parser$Parser$end)
				])));
}();
var $rtfeldman$elm_iso8601_date_strings$Iso8601$iso8601 = A2(
	$elm$parser$Parser$andThen,
	function (datePart) {
		return $elm$parser$Parser$oneOf(
			_List_fromArray(
				[
					A2(
					$elm$parser$Parser$keeper,
					A2(
						$elm$parser$Parser$keeper,
						A2(
							$elm$parser$Parser$keeper,
							A2(
								$elm$parser$Parser$keeper,
								A2(
									$elm$parser$Parser$keeper,
									A2(
										$elm$parser$Parser$ignorer,
										$elm$parser$Parser$succeed(
											$rtfeldman$elm_iso8601_date_strings$Iso8601$fromParts(datePart)),
										$elm$parser$Parser$symbol('T')),
									$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
								$elm$parser$Parser$oneOf(
									_List_fromArray(
										[
											A2(
											$elm$parser$Parser$keeper,
											A2(
												$elm$parser$Parser$ignorer,
												$elm$parser$Parser$succeed($elm$core$Basics$identity),
												$elm$parser$Parser$symbol(':')),
											$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
											$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)
										]))),
							$elm$parser$Parser$oneOf(
								_List_fromArray(
									[
										A2(
										$elm$parser$Parser$keeper,
										A2(
											$elm$parser$Parser$ignorer,
											$elm$parser$Parser$succeed($elm$core$Basics$identity),
											$elm$parser$Parser$symbol(':')),
										$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
										$rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2),
										$elm$parser$Parser$succeed(0)
									]))),
						$elm$parser$Parser$oneOf(
							_List_fromArray(
								[
									A2(
									$elm$parser$Parser$keeper,
									A2(
										$elm$parser$Parser$ignorer,
										$elm$parser$Parser$succeed($elm$core$Basics$identity),
										$elm$parser$Parser$symbol('.')),
									$rtfeldman$elm_iso8601_date_strings$Iso8601$fractionsOfASecondInMs),
									$elm$parser$Parser$succeed(0)
								]))),
					A2($elm$parser$Parser$ignorer, $rtfeldman$elm_iso8601_date_strings$Iso8601$utcOffsetInMinutes, $elm$parser$Parser$end)),
					A2(
					$elm$parser$Parser$ignorer,
					$elm$parser$Parser$succeed(
						A6($rtfeldman$elm_iso8601_date_strings$Iso8601$fromParts, datePart, 0, 0, 0, 0, 0)),
					$elm$parser$Parser$end)
				]));
	},
	$rtfeldman$elm_iso8601_date_strings$Iso8601$monthYearDayInMs);
var $elm$parser$Parser$DeadEnd = F3(
	function (row, col, problem) {
		return {col: col, problem: problem, row: row};
	});
var $elm$parser$Parser$problemToDeadEnd = function (p) {
	return A3($elm$parser$Parser$DeadEnd, p.row, p.col, p.problem);
};
var $elm$parser$Parser$Advanced$bagToList = F2(
	function (bag, list) {
		bagToList:
		while (true) {
			switch (bag.$) {
				case 'Empty':
					return list;
				case 'AddRight':
					var bag1 = bag.a;
					var x = bag.b;
					var $temp$bag = bag1,
						$temp$list = A2($elm$core$List$cons, x, list);
					bag = $temp$bag;
					list = $temp$list;
					continue bagToList;
				default:
					var bag1 = bag.a;
					var bag2 = bag.b;
					var $temp$bag = bag1,
						$temp$list = A2($elm$parser$Parser$Advanced$bagToList, bag2, list);
					bag = $temp$bag;
					list = $temp$list;
					continue bagToList;
			}
		}
	});
var $elm$parser$Parser$Advanced$run = F2(
	function (_v0, src) {
		var parse = _v0.a;
		var _v1 = parse(
			{col: 1, context: _List_Nil, indent: 1, offset: 0, row: 1, src: src});
		if (_v1.$ === 'Good') {
			var value = _v1.b;
			return $elm$core$Result$Ok(value);
		} else {
			var bag = _v1.b;
			return $elm$core$Result$Err(
				A2($elm$parser$Parser$Advanced$bagToList, bag, _List_Nil));
		}
	});
var $elm$parser$Parser$run = F2(
	function (parser, source) {
		var _v0 = A2($elm$parser$Parser$Advanced$run, parser, source);
		if (_v0.$ === 'Ok') {
			var a = _v0.a;
			return $elm$core$Result$Ok(a);
		} else {
			var problems = _v0.a;
			return $elm$core$Result$Err(
				A2($elm$core$List$map, $elm$parser$Parser$problemToDeadEnd, problems));
		}
	});
var $rtfeldman$elm_iso8601_date_strings$Iso8601$toTime = function (str) {
	return A2($elm$parser$Parser$run, $rtfeldman$elm_iso8601_date_strings$Iso8601$iso8601, str);
};
var $author$project$Api$Time$decodeDateIsoString = function (str) {
	var _v0 = $rtfeldman$elm_iso8601_date_strings$Iso8601$toTime(str + 'T00:00:00.000Z');
	if (_v0.$ === 'Ok') {
		var posix = _v0.a;
		return $elm$json$Json$Decode$succeed(posix);
	} else {
		return $elm$json$Json$Decode$fail('Invalid calendar date: ' + str);
	}
};
var $author$project$Api$Time$dateDecoder = A2($elm$json$Json$Decode$andThen, $author$project$Api$Time$decodeDateIsoString, $elm$json$Json$Decode$string);
var $author$project$Api$Time$decodeDateTimeIsoString = function (str) {
	var _v0 = $rtfeldman$elm_iso8601_date_strings$Iso8601$toTime(str);
	if (_v0.$ === 'Ok') {
		var posix = _v0.a;
		return $elm$json$Json$Decode$succeed(posix);
	} else {
		return $elm$json$Json$Decode$fail('Invalid ISO date: ' + str);
	}
};
var $author$project$Api$Time$dateTimeDecoder = A2($elm$json$Json$Decode$andThen, $author$project$Api$Time$decodeDateTimeIsoString, $elm$json$Json$Decode$string);
var $author$project$Api$Data$userDecoder = A4(
	$author$project$Api$Data$maybeDecode,
	'children',
	$elm$json$Json$Decode$list($danyx23$elm_uuid$Uuid$decoder),
	$elm$core$Maybe$Nothing,
	A4(
		$author$project$Api$Data$maybeDecode,
		'user_permissions',
		$elm$json$Json$Decode$list($elm$json$Json$Decode$int),
		$elm$core$Maybe$Nothing,
		A4(
			$author$project$Api$Data$maybeDecode,
			'groups',
			$elm$json$Json$Decode$list($elm$json$Json$Decode$int),
			$elm$core$Maybe$Nothing,
			A4(
				$author$project$Api$Data$maybeDecodeNullable,
				'avatar',
				$elm$json$Json$Decode$string,
				$elm$core$Maybe$Nothing,
				A4(
					$author$project$Api$Data$maybeDecodeNullable,
					'birth_date',
					$author$project$Api$Time$dateDecoder,
					$elm$core$Maybe$Nothing,
					A4(
						$author$project$Api$Data$maybeDecodeNullable,
						'middle_name',
						$elm$json$Json$Decode$string,
						$elm$core$Maybe$Nothing,
						A4(
							$author$project$Api$Data$maybeDecode,
							'date_joined',
							$author$project$Api$Time$dateTimeDecoder,
							$elm$core$Maybe$Nothing,
							A4(
								$author$project$Api$Data$maybeDecode,
								'is_active',
								$elm$json$Json$Decode$bool,
								$elm$core$Maybe$Nothing,
								A4(
									$author$project$Api$Data$maybeDecode,
									'is_staff',
									$elm$json$Json$Decode$bool,
									$elm$core$Maybe$Nothing,
									A4(
										$author$project$Api$Data$maybeDecode,
										'email',
										$elm$json$Json$Decode$string,
										$elm$core$Maybe$Nothing,
										A4(
											$author$project$Api$Data$maybeDecode,
											'last_name',
											$elm$json$Json$Decode$string,
											$elm$core$Maybe$Nothing,
											A4(
												$author$project$Api$Data$maybeDecode,
												'first_name',
												$elm$json$Json$Decode$string,
												$elm$core$Maybe$Nothing,
												A3(
													$author$project$Api$Data$decode,
													'username',
													$elm$json$Json$Decode$string,
													A4(
														$author$project$Api$Data$maybeDecode,
														'is_superuser',
														$elm$json$Json$Decode$bool,
														$elm$core$Maybe$Nothing,
														A4(
															$author$project$Api$Data$maybeDecodeNullable,
															'last_login',
															$author$project$Api$Time$dateTimeDecoder,
															$elm$core$Maybe$Nothing,
															A4(
																$author$project$Api$Data$maybeDecode,
																'id',
																$danyx23$elm_uuid$Uuid$decoder,
																$elm$core$Maybe$Nothing,
																$elm$json$Json$Decode$succeed($author$project$Api$Data$User)))))))))))))))));
var $author$project$Api$Request$User$userSelf = A7($author$project$Api$request, 'GET', '/user/self/', _List_Nil, _List_Nil, _List_Nil, $elm$core$Maybe$Nothing, $author$project$Api$Data$userDecoder);
var $author$project$Page$Login$doCheckSession = function (token) {
	var task_user = A2(
		$elm$core$Task$mapError,
		function (e) {
			return $elm$core$Maybe$Just(
				'Произошла ошибка при попытке восстановить текущую сессию. Возможно, имеются проблемы ' + ('с вашим интенет-подключением или сервер API в данный момент недоступен: ' + $author$project$Util$httpErrorToString(e)));
		},
		$author$project$Api$task(
			A2(
				$author$project$Api$withToken,
				$elm$core$Maybe$Just(token),
				$author$project$Api$Request$User$userSelf)));
	var hide_error = $elm$core$Task$mapError(
		function (_v1) {
			return $elm$core$Maybe$Nothing;
		});
	var task_date = hide_error($elm$time$Time$now);
	return A3(
		$author$project$Util$task_to_cmd,
		function (err) {
			return (token === '') ? $author$project$Page$Login$ShowLogin : $author$project$Page$Login$CheckSessionFailed(
				A2($elm$core$Maybe$withDefault, '', err));
		},
		function (_v0) {
			var user = _v0.a;
			var time = _v0.b;
			return $author$project$Page$Login$LoginCompleted(
				{key: token, user: user});
		},
		A3(
			$elm$core$Task$map2,
			F2(
				function (x, y) {
					return _Utils_Tuple2(x, y);
				}),
			task_user,
			task_date));
};
var $author$project$Page$Login$init = function (token) {
	return _Utils_Tuple2(
		{message: $author$project$Page$Login$None, password: '', state: $author$project$Page$Login$CheckingStored, token: token, username: ''},
		$author$project$Page$Login$doCheckSession(token));
};
var $elm$browser$Browser$Navigation$load = _Browser_load;
var $elm$core$Debug$log = _Debug_log;
var $author$project$Main$UrlCourse = function (a) {
	return {$: 'UrlCourse', a: a};
};
var $author$project$Main$UrlCourseList = {$: 'UrlCourseList'};
var $author$project$Main$UrlLogin = {$: 'UrlLogin'};
var $author$project$Main$UrlLogout = {$: 'UrlLogout'};
var $author$project$Main$UrlMainPage = {$: 'UrlMainPage'};
var $author$project$Main$UrlMarksOfCourse = function (a) {
	return {$: 'UrlMarksOfCourse', a: a};
};
var $author$project$Main$UrlMarksOfPerson = function (a) {
	return {$: 'UrlMarksOfPerson', a: a};
};
var $author$project$Main$UrlMarksOwn = {$: 'UrlMarksOwn'};
var $author$project$Main$UrlMessages = {$: 'UrlMessages'};
var $author$project$Main$UrlNews = {$: 'UrlNews'};
var $author$project$Main$UrlNotFound = {$: 'UrlNotFound'};
var $author$project$Main$UrlProfileOfUser = function (a) {
	return {$: 'UrlProfileOfUser', a: a};
};
var $author$project$Main$UrlProfileOwn = {$: 'UrlProfileOwn'};
var $elm$url$Url$Parser$Parser = function (a) {
	return {$: 'Parser', a: a};
};
var $elm$url$Url$Parser$State = F5(
	function (visited, unvisited, params, frag, value) {
		return {frag: frag, params: params, unvisited: unvisited, value: value, visited: visited};
	});
var $elm$url$Url$Parser$mapState = F2(
	function (func, _v0) {
		var visited = _v0.visited;
		var unvisited = _v0.unvisited;
		var params = _v0.params;
		var frag = _v0.frag;
		var value = _v0.value;
		return A5(
			$elm$url$Url$Parser$State,
			visited,
			unvisited,
			params,
			frag,
			func(value));
	});
var $elm$url$Url$Parser$map = F2(
	function (subValue, _v0) {
		var parseArg = _v0.a;
		return $elm$url$Url$Parser$Parser(
			function (_v1) {
				var visited = _v1.visited;
				var unvisited = _v1.unvisited;
				var params = _v1.params;
				var frag = _v1.frag;
				var value = _v1.value;
				return A2(
					$elm$core$List$map,
					$elm$url$Url$Parser$mapState(value),
					parseArg(
						A5($elm$url$Url$Parser$State, visited, unvisited, params, frag, subValue)));
			});
	});
var $elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3($elm$core$List$foldr, $elm$core$List$cons, ys, xs);
		}
	});
var $elm$core$List$concat = function (lists) {
	return A3($elm$core$List$foldr, $elm$core$List$append, _List_Nil, lists);
};
var $elm$core$List$concatMap = F2(
	function (f, list) {
		return $elm$core$List$concat(
			A2($elm$core$List$map, f, list));
	});
var $elm$url$Url$Parser$oneOf = function (parsers) {
	return $elm$url$Url$Parser$Parser(
		function (state) {
			return A2(
				$elm$core$List$concatMap,
				function (_v0) {
					var parser = _v0.a;
					return parser(state);
				},
				parsers);
		});
};
var $elm$url$Url$Parser$getFirstMatch = function (states) {
	getFirstMatch:
	while (true) {
		if (!states.b) {
			return $elm$core$Maybe$Nothing;
		} else {
			var state = states.a;
			var rest = states.b;
			var _v1 = state.unvisited;
			if (!_v1.b) {
				return $elm$core$Maybe$Just(state.value);
			} else {
				if ((_v1.a === '') && (!_v1.b.b)) {
					return $elm$core$Maybe$Just(state.value);
				} else {
					var $temp$states = rest;
					states = $temp$states;
					continue getFirstMatch;
				}
			}
		}
	}
};
var $elm$url$Url$Parser$removeFinalEmpty = function (segments) {
	if (!segments.b) {
		return _List_Nil;
	} else {
		if ((segments.a === '') && (!segments.b.b)) {
			return _List_Nil;
		} else {
			var segment = segments.a;
			var rest = segments.b;
			return A2(
				$elm$core$List$cons,
				segment,
				$elm$url$Url$Parser$removeFinalEmpty(rest));
		}
	}
};
var $elm$url$Url$Parser$preparePath = function (path) {
	var _v0 = A2($elm$core$String$split, '/', path);
	if (_v0.b && (_v0.a === '')) {
		var segments = _v0.b;
		return $elm$url$Url$Parser$removeFinalEmpty(segments);
	} else {
		var segments = _v0;
		return $elm$url$Url$Parser$removeFinalEmpty(segments);
	}
};
var $elm$url$Url$Parser$addToParametersHelp = F2(
	function (value, maybeList) {
		if (maybeList.$ === 'Nothing') {
			return $elm$core$Maybe$Just(
				_List_fromArray(
					[value]));
		} else {
			var list = maybeList.a;
			return $elm$core$Maybe$Just(
				A2($elm$core$List$cons, value, list));
		}
	});
var $elm$url$Url$percentDecode = _Url_percentDecode;
var $elm$url$Url$Parser$addParam = F2(
	function (segment, dict) {
		var _v0 = A2($elm$core$String$split, '=', segment);
		if ((_v0.b && _v0.b.b) && (!_v0.b.b.b)) {
			var rawKey = _v0.a;
			var _v1 = _v0.b;
			var rawValue = _v1.a;
			var _v2 = $elm$url$Url$percentDecode(rawKey);
			if (_v2.$ === 'Nothing') {
				return dict;
			} else {
				var key = _v2.a;
				var _v3 = $elm$url$Url$percentDecode(rawValue);
				if (_v3.$ === 'Nothing') {
					return dict;
				} else {
					var value = _v3.a;
					return A3(
						$elm$core$Dict$update,
						key,
						$elm$url$Url$Parser$addToParametersHelp(value),
						dict);
				}
			}
		} else {
			return dict;
		}
	});
var $elm$url$Url$Parser$prepareQuery = function (maybeQuery) {
	if (maybeQuery.$ === 'Nothing') {
		return $elm$core$Dict$empty;
	} else {
		var qry = maybeQuery.a;
		return A3(
			$elm$core$List$foldr,
			$elm$url$Url$Parser$addParam,
			$elm$core$Dict$empty,
			A2($elm$core$String$split, '&', qry));
	}
};
var $elm$url$Url$Parser$parse = F2(
	function (_v0, url) {
		var parser = _v0.a;
		return $elm$url$Url$Parser$getFirstMatch(
			parser(
				A5(
					$elm$url$Url$Parser$State,
					_List_Nil,
					$elm$url$Url$Parser$preparePath(url.path),
					$elm$url$Url$Parser$prepareQuery(url.query),
					url.fragment,
					$elm$core$Basics$identity)));
	});
var $elm$url$Url$Parser$s = function (str) {
	return $elm$url$Url$Parser$Parser(
		function (_v0) {
			var visited = _v0.visited;
			var unvisited = _v0.unvisited;
			var params = _v0.params;
			var frag = _v0.frag;
			var value = _v0.value;
			if (!unvisited.b) {
				return _List_Nil;
			} else {
				var next = unvisited.a;
				var rest = unvisited.b;
				return _Utils_eq(next, str) ? _List_fromArray(
					[
						A5(
						$elm$url$Url$Parser$State,
						A2($elm$core$List$cons, next, visited),
						rest,
						params,
						frag,
						value)
					]) : _List_Nil;
			}
		});
};
var $elm$url$Url$Parser$slash = F2(
	function (_v0, _v1) {
		var parseBefore = _v0.a;
		var parseAfter = _v1.a;
		return $elm$url$Url$Parser$Parser(
			function (state) {
				return A2(
					$elm$core$List$concatMap,
					parseAfter,
					parseBefore(state));
			});
	});
var $elm$url$Url$Parser$custom = F2(
	function (tipe, stringToSomething) {
		return $elm$url$Url$Parser$Parser(
			function (_v0) {
				var visited = _v0.visited;
				var unvisited = _v0.unvisited;
				var params = _v0.params;
				var frag = _v0.frag;
				var value = _v0.value;
				if (!unvisited.b) {
					return _List_Nil;
				} else {
					var next = unvisited.a;
					var rest = unvisited.b;
					var _v2 = stringToSomething(next);
					if (_v2.$ === 'Just') {
						var nextValue = _v2.a;
						return _List_fromArray(
							[
								A5(
								$elm$url$Url$Parser$State,
								A2($elm$core$List$cons, next, visited),
								rest,
								params,
								frag,
								value(nextValue))
							]);
					} else {
						return _List_Nil;
					}
				}
			});
	});
var $elm$url$Url$Parser$string = A2($elm$url$Url$Parser$custom, 'STRING', $elm$core$Maybe$Just);
var $elm$url$Url$Parser$top = $elm$url$Url$Parser$Parser(
	function (state) {
		return _List_fromArray(
			[state]);
	});
var $author$project$Main$parse_url = function (url) {
	return A2(
		$elm$core$Maybe$withDefault,
		$author$project$Main$UrlNotFound,
		A2(
			$elm$url$Url$Parser$parse,
			$elm$url$Url$Parser$oneOf(
				_List_fromArray(
					[
						A2($elm$url$Url$Parser$map, $author$project$Main$UrlMainPage, $elm$url$Url$Parser$top),
						A2(
						$elm$url$Url$Parser$map,
						$author$project$Main$UrlLogin,
						$elm$url$Url$Parser$s('login')),
						A2(
						$elm$url$Url$Parser$map,
						$author$project$Main$UrlLogout,
						$elm$url$Url$Parser$s('logout')),
						A2(
						$elm$url$Url$Parser$map,
						$author$project$Main$UrlCourseList,
						$elm$url$Url$Parser$s('course')),
						A2(
						$elm$url$Url$Parser$map,
						$author$project$Main$UrlCourse,
						A2(
							$elm$url$Url$Parser$slash,
							$elm$url$Url$Parser$s('course'),
							$elm$url$Url$Parser$string)),
						A2(
						$elm$url$Url$Parser$map,
						$author$project$Main$UrlMarksOwn,
						$elm$url$Url$Parser$s('marks')),
						A2(
						$elm$url$Url$Parser$map,
						$author$project$Main$UrlMarksOfPerson,
						A2(
							$elm$url$Url$Parser$slash,
							$elm$url$Url$Parser$s('marks'),
							A2(
								$elm$url$Url$Parser$slash,
								$elm$url$Url$Parser$s('user'),
								$elm$url$Url$Parser$string))),
						A2(
						$elm$url$Url$Parser$map,
						$author$project$Main$UrlMarksOfCourse,
						A2(
							$elm$url$Url$Parser$slash,
							$elm$url$Url$Parser$s('marks'),
							A2(
								$elm$url$Url$Parser$slash,
								$elm$url$Url$Parser$s('course'),
								$elm$url$Url$Parser$string))),
						A2(
						$elm$url$Url$Parser$map,
						$author$project$Main$UrlProfileOwn,
						$elm$url$Url$Parser$s('profile')),
						A2(
						$elm$url$Url$Parser$map,
						$author$project$Main$UrlProfileOfUser,
						A2(
							$elm$url$Url$Parser$slash,
							$elm$url$Url$Parser$s('profile'),
							$elm$url$Url$Parser$string)),
						A2(
						$elm$url$Url$Parser$map,
						$author$project$Main$UrlMessages,
						$elm$url$Url$Parser$s('messages')),
						A2(
						$elm$url$Url$Parser$map,
						$author$project$Main$UrlNews,
						$elm$url$Url$Parser$s('news'))
					])),
			url));
};
var $elm$url$Url$addPort = F2(
	function (maybePort, starter) {
		if (maybePort.$ === 'Nothing') {
			return starter;
		} else {
			var port_ = maybePort.a;
			return starter + (':' + $elm$core$String$fromInt(port_));
		}
	});
var $elm$url$Url$addPrefixed = F3(
	function (prefix, maybeSegment, starter) {
		if (maybeSegment.$ === 'Nothing') {
			return starter;
		} else {
			var segment = maybeSegment.a;
			return _Utils_ap(
				starter,
				_Utils_ap(prefix, segment));
		}
	});
var $elm$url$Url$toString = function (url) {
	var http = function () {
		var _v0 = url.protocol;
		if (_v0.$ === 'Http') {
			return 'http://';
		} else {
			return 'https://';
		}
	}();
	return A3(
		$elm$url$Url$addPrefixed,
		'#',
		url.fragment,
		A3(
			$elm$url$Url$addPrefixed,
			'?',
			url.query,
			_Utils_ap(
				A2(
					$elm$url$Url$addPort,
					url.port_,
					_Utils_ap(http, url.host)),
				url.path)));
};
var $author$project$Page$CourseListPage$Completed = function (a) {
	return {$: 'Completed', a: a};
};
var $author$project$Page$CourseListPage$Error = function (a) {
	return {$: 'Error', a: a};
};
var $author$project$Page$CourseListPage$empty_to_nothing = function (x) {
	if ((x.$ === 'Just') && (x.a === '')) {
		return $elm$core$Maybe$Nothing;
	} else {
		return x;
	}
};
var $author$project$Page$CourseListPage$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'GotCourses':
				var cs = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							state: $author$project$Page$CourseListPage$Completed(
								A2(
									$elm$core$List$map,
									function (c) {
										return _Utils_update(
											c,
											{
												forClass: $author$project$Page$CourseListPage$empty_to_nothing(c.forClass),
												forGroup: $author$project$Page$CourseListPage$empty_to_nothing(c.forGroup)
											});
									},
									cs))
						}),
					$elm$core$Platform$Cmd$none);
			case 'CourseListFetchFailed':
				var err = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							state: $author$project$Page$CourseListPage$Error(err)
						}),
					$elm$core$Platform$Cmd$none);
			default:
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{state: $author$project$Page$CourseListPage$Loading}),
					$author$project$Page$CourseListPage$doFetchCourses(model.token));
		}
	});
var $author$project$Page$CoursePage$FetchDone = F2(
	function (a, b) {
		return {$: 'FetchDone', a: a, b: b};
	});
var $author$project$Page$CoursePage$FetchFailed = function (a) {
	return {$: 'FetchFailed', a: a};
};
var $author$project$Page$CoursePage$collectFetchResults = function (fetchResults) {
	_v0$2:
	while (true) {
		if (fetchResults.b && (fetchResults.a.$ === 'Ok')) {
			if (fetchResults.a.a.$ === 'ResCourse') {
				if (((fetchResults.b.b && (fetchResults.b.a.$ === 'Ok')) && (fetchResults.b.a.a.$ === 'ResActivities')) && (!fetchResults.b.b.b)) {
					var c = fetchResults.a.a.a;
					var _v1 = fetchResults.b;
					var a = _v1.a.a.a;
					return $elm$core$Maybe$Just(
						_Utils_Tuple2(c, a));
				} else {
					break _v0$2;
				}
			} else {
				if (((fetchResults.b.b && (fetchResults.b.a.$ === 'Ok')) && (fetchResults.b.a.a.$ === 'ResCourse')) && (!fetchResults.b.b.b)) {
					var a = fetchResults.a.a.a;
					var _v2 = fetchResults.b;
					var c = _v2.a.a.a;
					return $elm$core$Maybe$Just(
						_Utils_Tuple2(c, a));
				} else {
					break _v0$2;
				}
			}
		} else {
			break _v0$2;
		}
	}
	return $elm$core$Maybe$Nothing;
};
var $author$project$Component$MultiTask$Complete = function (a) {
	return {$: 'Complete', a: a};
};
var $author$project$Component$MultiTask$Error = function (a) {
	return {$: 'Error', a: a};
};
var $author$project$Component$MultiTask$TaskFinishedAll = function (a) {
	return {$: 'TaskFinishedAll', a: a};
};
var $elm$core$Bitwise$and = _Bitwise_and;
var $elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var $elm$core$Array$bitMask = 4294967295 >>> (32 - $elm$core$Array$shiftStep);
var $elm$core$Basics$ge = _Utils_ge;
var $elm$core$Elm$JsArray$unsafeGet = _JsArray_unsafeGet;
var $elm$core$Array$getHelp = F3(
	function (shift, index, tree) {
		getHelp:
		while (true) {
			var pos = $elm$core$Array$bitMask & (index >>> shift);
			var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (_v0.$ === 'SubTree') {
				var subTree = _v0.a;
				var $temp$shift = shift - $elm$core$Array$shiftStep,
					$temp$index = index,
					$temp$tree = subTree;
				shift = $temp$shift;
				index = $temp$index;
				tree = $temp$tree;
				continue getHelp;
			} else {
				var values = _v0.a;
				return A2($elm$core$Elm$JsArray$unsafeGet, $elm$core$Array$bitMask & index, values);
			}
		}
	});
var $elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var $elm$core$Array$tailIndex = function (len) {
	return (len >>> 5) << 5;
};
var $elm$core$Array$get = F2(
	function (index, _v0) {
		var len = _v0.a;
		var startShift = _v0.b;
		var tree = _v0.c;
		var tail = _v0.d;
		return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? $elm$core$Maybe$Nothing : ((_Utils_cmp(
			index,
			$elm$core$Array$tailIndex(len)) > -1) ? $elm$core$Maybe$Just(
			A2($elm$core$Elm$JsArray$unsafeGet, $elm$core$Array$bitMask & index, tail)) : $elm$core$Maybe$Just(
			A3($elm$core$Array$getHelp, startShift, index, tree)));
	});
var $elm$core$Elm$JsArray$unsafeSet = _JsArray_unsafeSet;
var $elm$core$Array$setHelp = F4(
	function (shift, index, value, tree) {
		var pos = $elm$core$Array$bitMask & (index >>> shift);
		var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
		if (_v0.$ === 'SubTree') {
			var subTree = _v0.a;
			var newSub = A4($elm$core$Array$setHelp, shift - $elm$core$Array$shiftStep, index, value, subTree);
			return A3(
				$elm$core$Elm$JsArray$unsafeSet,
				pos,
				$elm$core$Array$SubTree(newSub),
				tree);
		} else {
			var values = _v0.a;
			var newLeaf = A3($elm$core$Elm$JsArray$unsafeSet, $elm$core$Array$bitMask & index, value, values);
			return A3(
				$elm$core$Elm$JsArray$unsafeSet,
				pos,
				$elm$core$Array$Leaf(newLeaf),
				tree);
		}
	});
var $elm$core$Array$set = F3(
	function (index, value, array) {
		var len = array.a;
		var startShift = array.b;
		var tree = array.c;
		var tail = array.d;
		return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? array : ((_Utils_cmp(
			index,
			$elm$core$Array$tailIndex(len)) > -1) ? A4(
			$elm$core$Array$Array_elm_builtin,
			len,
			startShift,
			tree,
			A3($elm$core$Elm$JsArray$unsafeSet, $elm$core$Array$bitMask & index, value, tail)) : A4(
			$elm$core$Array$Array_elm_builtin,
			len,
			startShift,
			A4($elm$core$Array$setHelp, startShift, index, value, tree),
			tail));
	});
var $author$project$Util$arrayUpdate = F3(
	function (ix, transform, array) {
		var ignore = A2(
			$elm$core$Debug$log,
			'arrayUpdate',
			_Utils_Tuple3(ix, transform, array));
		var _v0 = A2($elm$core$Array$get, ix, array);
		if (_v0.$ === 'Just') {
			var el = _v0.a;
			return A2(
				$elm$core$Debug$log,
				'arrayUpdate: succeded',
				A3(
					$elm$core$Array$set,
					ix,
					transform(el),
					array));
		} else {
			return A2($elm$core$Debug$log, 'arrayUpdate: failed', array);
		}
	});
var $author$project$Component$MultiTask$collectResults = function (model) {
	var state2result = function (state) {
		switch (state.$) {
			case 'Running':
				return $elm$core$Maybe$Nothing;
			case 'Complete':
				var r = state.a;
				return $elm$core$Maybe$Just(
					$elm$core$Result$Ok(r));
			default:
				var e = state.a;
				return $elm$core$Maybe$Just(
					$elm$core$Result$Err(e));
		}
	};
	return A2(
		$elm$core$List$filterMap,
		$elm$core$Basics$identity,
		$elm$core$Array$toList(
			A2(
				$elm$core$Array$map,
				A2(
					$elm$core$Basics$composeL,
					state2result,
					function (_v0) {
						var s = _v0.b;
						return s;
					}),
				model.task_states)));
};
var $author$project$Component$MultiTask$update = F2(
	function (msg, model_) {
		var model = A2($elm$core$Debug$log, 'model_', model_);
		var _v0 = A2($elm$core$Debug$log, 'msg', msg);
		switch (_v0.$) {
			case 'TaskCompleted':
				var i = _v0.a;
				var res = _v0.b;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							task_states: A3(
								$author$project$Util$arrayUpdate,
								i,
								function (_v1) {
									var l = _v1.a;
									var t = _v1.c;
									return _Utils_Tuple3(
										l,
										$author$project$Component$MultiTask$Complete(res),
										t);
								},
								model.task_states),
							tasks_left: model.tasks_left - 1
						}),
					(model.tasks_left <= 1) ? A2(
						$elm$core$Task$perform,
						function (_v2) {
							return $author$project$Component$MultiTask$TaskFinishedAll(
								$author$project$Component$MultiTask$collectResults(model));
						},
						$elm$core$Task$succeed(_Utils_Tuple0)) : $elm$core$Platform$Cmd$none);
			case 'TaskFailed':
				var i = _v0.a;
				var err = _v0.b;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							task_states: A3(
								$author$project$Util$arrayUpdate,
								i,
								function (_v3) {
									var l = _v3.a;
									var t = _v3.c;
									return _Utils_Tuple3(
										l,
										$author$project$Component$MultiTask$Error(err),
										t);
								},
								model.task_states)
						}),
					$elm$core$Platform$Cmd$none);
			default:
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Page$CoursePage$update = F2(
	function (msg, model) {
		var _v0 = _Utils_Tuple2(msg, model.state);
		if (_v0.b.$ === 'Fetching') {
			var msg_ = _v0.a.a;
			var model_ = _v0.b.a;
			var _v1 = A2($author$project$Component$MultiTask$update, msg_, model_);
			var m = _v1.a;
			var c = _v1.b;
			if (msg_.$ === 'TaskFinishedAll') {
				var results = msg_.a;
				var _v3 = $author$project$Page$CoursePage$collectFetchResults(results);
				if (_v3.$ === 'Just') {
					var _v4 = _v3.a;
					var c_ = _v4.a;
					var a = _v4.b;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								state: A2($author$project$Page$CoursePage$FetchDone, c_, a)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								state: $author$project$Page$CoursePage$FetchFailed('Не удалось разобрать результаты запросов')
							}),
						$elm$core$Platform$Cmd$none);
				}
			} else {
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			}
		} else {
			return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Page$DefaultLayout$update = F2(
	function (msg, model) {
		if (msg.$ === 'SidebarToggle') {
			return _Utils_Tuple2(
				_Utils_update(
					model,
					{show_sidebar: !model.show_sidebar}),
				$elm$core$Platform$Cmd$none);
		} else {
			return _Utils_Tuple2(
				_Utils_update(
					model,
					{show_sidebar: false}),
				$elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Page$Login$Error = function (a) {
	return {$: 'Error', a: a};
};
var $author$project$Page$Login$LoggingIn = {$: 'LoggingIn'};
var $author$project$Page$Login$Login = {$: 'Login'};
var $author$project$Page$Login$PasswordReset = {$: 'PasswordReset'};
var $author$project$Page$Login$ResettingPassword = {$: 'ResettingPassword'};
var $author$project$Page$Login$Success = function (a) {
	return {$: 'Success', a: a};
};
var $author$project$Page$Login$LoginFailed = function (a) {
	return {$: 'LoginFailed', a: a};
};
var $elm$http$Http$expectStringResponse = F2(
	function (toMsg, toResult) {
		return A3(
			_Http_expect,
			'',
			$elm$core$Basics$identity,
			A2($elm$core$Basics$composeR, toResult, toMsg));
	});
var $elm$core$Result$mapError = F2(
	function (f, result) {
		if (result.$ === 'Ok') {
			var v = result.a;
			return $elm$core$Result$Ok(v);
		} else {
			var e = result.a;
			return $elm$core$Result$Err(
				f(e));
		}
	});
var $author$project$Api$expectJson = F3(
	function (mapError, toMsg, decoder) {
		return A2(
			$elm$http$Http$expectStringResponse,
			toMsg,
			A2(
				$elm$core$Basics$composeL,
				$elm$core$Result$mapError(mapError),
				$author$project$Api$decodeResponse(decoder)));
	});
var $elm$http$Http$Request = function (a) {
	return {$: 'Request', a: a};
};
var $elm$http$Http$State = F2(
	function (reqs, subs) {
		return {reqs: reqs, subs: subs};
	});
var $elm$http$Http$init = $elm$core$Task$succeed(
	A2($elm$http$Http$State, $elm$core$Dict$empty, _List_Nil));
var $elm$core$Process$kill = _Scheduler_kill;
var $elm$core$Process$spawn = _Scheduler_spawn;
var $elm$http$Http$updateReqs = F3(
	function (router, cmds, reqs) {
		updateReqs:
		while (true) {
			if (!cmds.b) {
				return $elm$core$Task$succeed(reqs);
			} else {
				var cmd = cmds.a;
				var otherCmds = cmds.b;
				if (cmd.$ === 'Cancel') {
					var tracker = cmd.a;
					var _v2 = A2($elm$core$Dict$get, tracker, reqs);
					if (_v2.$ === 'Nothing') {
						var $temp$router = router,
							$temp$cmds = otherCmds,
							$temp$reqs = reqs;
						router = $temp$router;
						cmds = $temp$cmds;
						reqs = $temp$reqs;
						continue updateReqs;
					} else {
						var pid = _v2.a;
						return A2(
							$elm$core$Task$andThen,
							function (_v3) {
								return A3(
									$elm$http$Http$updateReqs,
									router,
									otherCmds,
									A2($elm$core$Dict$remove, tracker, reqs));
							},
							$elm$core$Process$kill(pid));
					}
				} else {
					var req = cmd.a;
					return A2(
						$elm$core$Task$andThen,
						function (pid) {
							var _v4 = req.tracker;
							if (_v4.$ === 'Nothing') {
								return A3($elm$http$Http$updateReqs, router, otherCmds, reqs);
							} else {
								var tracker = _v4.a;
								return A3(
									$elm$http$Http$updateReqs,
									router,
									otherCmds,
									A3($elm$core$Dict$insert, tracker, pid, reqs));
							}
						},
						$elm$core$Process$spawn(
							A3(
								_Http_toTask,
								router,
								$elm$core$Platform$sendToApp(router),
								req)));
				}
			}
		}
	});
var $elm$http$Http$onEffects = F4(
	function (router, cmds, subs, state) {
		return A2(
			$elm$core$Task$andThen,
			function (reqs) {
				return $elm$core$Task$succeed(
					A2($elm$http$Http$State, reqs, subs));
			},
			A3($elm$http$Http$updateReqs, router, cmds, state.reqs));
	});
var $elm$http$Http$maybeSend = F4(
	function (router, desiredTracker, progress, _v0) {
		var actualTracker = _v0.a;
		var toMsg = _v0.b;
		return _Utils_eq(desiredTracker, actualTracker) ? $elm$core$Maybe$Just(
			A2(
				$elm$core$Platform$sendToApp,
				router,
				toMsg(progress))) : $elm$core$Maybe$Nothing;
	});
var $elm$http$Http$onSelfMsg = F3(
	function (router, _v0, state) {
		var tracker = _v0.a;
		var progress = _v0.b;
		return A2(
			$elm$core$Task$andThen,
			function (_v1) {
				return $elm$core$Task$succeed(state);
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$filterMap,
					A3($elm$http$Http$maybeSend, router, tracker, progress),
					state.subs)));
	});
var $elm$http$Http$Cancel = function (a) {
	return {$: 'Cancel', a: a};
};
var $elm$http$Http$cmdMap = F2(
	function (func, cmd) {
		if (cmd.$ === 'Cancel') {
			var tracker = cmd.a;
			return $elm$http$Http$Cancel(tracker);
		} else {
			var r = cmd.a;
			return $elm$http$Http$Request(
				{
					allowCookiesFromOtherDomains: r.allowCookiesFromOtherDomains,
					body: r.body,
					expect: A2(_Http_mapExpect, func, r.expect),
					headers: r.headers,
					method: r.method,
					timeout: r.timeout,
					tracker: r.tracker,
					url: r.url
				});
		}
	});
var $elm$http$Http$MySub = F2(
	function (a, b) {
		return {$: 'MySub', a: a, b: b};
	});
var $elm$http$Http$subMap = F2(
	function (func, _v0) {
		var tracker = _v0.a;
		var toMsg = _v0.b;
		return A2(
			$elm$http$Http$MySub,
			tracker,
			A2($elm$core$Basics$composeR, toMsg, func));
	});
_Platform_effectManagers['Http'] = _Platform_createManager($elm$http$Http$init, $elm$http$Http$onEffects, $elm$http$Http$onSelfMsg, $elm$http$Http$cmdMap, $elm$http$Http$subMap);
var $elm$http$Http$command = _Platform_leaf('Http');
var $elm$http$Http$subscription = _Platform_leaf('Http');
var $elm$http$Http$request = function (r) {
	return $elm$http$Http$command(
		$elm$http$Http$Request(
			{allowCookiesFromOtherDomains: false, body: r.body, expect: r.expect, headers: r.headers, method: r.method, timeout: r.timeout, tracker: r.tracker, url: r.url}));
};
var $author$project$Api$sendWithCustomError = F3(
	function (mapError, toMsg, _v0) {
		var req = _v0.a;
		return $elm$http$Http$request(
			{
				body: req.body,
				expect: A3($author$project$Api$expectJson, mapError, toMsg, req.decoder),
				headers: req.headers,
				method: req.method,
				timeout: req.timeout,
				tracker: req.tracker,
				url: A3($elm$url$Url$Builder$crossOrigin, req.basePath, req.pathParams, req.queryParams)
			});
	});
var $author$project$Api$send = F2(
	function (toMsg, req) {
		return A3($author$project$Api$sendWithCustomError, $elm$core$Basics$identity, toMsg, req);
	});
var $author$project$Api$Data$encode = F3(
	function (key, encoder, value) {
		return $elm$core$Maybe$Just(
			_Utils_Tuple2(
				key,
				encoder(value)));
	});
var $author$project$Api$Data$encodeLoginPairs = function (model) {
	var pairs = _List_fromArray(
		[
			A3($author$project$Api$Data$encode, 'username', $elm$json$Json$Encode$string, model.username),
			A3($author$project$Api$Data$encode, 'password', $elm$json$Json$Encode$string, model.password)
		]);
	return pairs;
};
var $author$project$Api$Data$encodeObject = A2(
	$elm$core$Basics$composeL,
	$elm$json$Json$Encode$object,
	$elm$core$List$filterMap($elm$core$Basics$identity));
var $author$project$Api$Data$encodeLogin = A2($elm$core$Basics$composeL, $author$project$Api$Data$encodeObject, $author$project$Api$Data$encodeLoginPairs);
var $author$project$Api$Data$Token = F2(
	function (user, key) {
		return {key: key, user: user};
	});
var $author$project$Api$Data$tokenDecoder = A3(
	$author$project$Api$Data$decode,
	'key',
	$elm$json$Json$Decode$string,
	A3(
		$author$project$Api$Data$decode,
		'user',
		$author$project$Api$Data$userDecoder,
		$elm$json$Json$Decode$succeed($author$project$Api$Data$Token)));
var $author$project$Api$Request$User$userLogin = function (data_body) {
	return A7(
		$author$project$Api$request,
		'POST',
		'/user/login/',
		_List_Nil,
		_List_Nil,
		_List_Nil,
		$elm$core$Maybe$Just(
			$author$project$Api$Data$encodeLogin(data_body)),
		$author$project$Api$Data$tokenDecoder);
};
var $author$project$Page$Login$doLogin = F2(
	function (username, password) {
		var onResult = function (r) {
			if (r.$ === 'Ok') {
				var token = r.a;
				return $author$project$Page$Login$LoginCompleted(token);
			} else {
				if ((r.a.$ === 'BadStatus') && (r.a.a === 403)) {
					return $author$project$Page$Login$LoginFailed('Неправильно указаны данные учетной записи');
				} else {
					var e = r.a;
					return $author$project$Page$Login$LoginFailed(
						$author$project$Util$httpErrorToString(e));
				}
			}
		};
		return A2(
			$author$project$Api$send,
			onResult,
			$author$project$Api$Request$User$userLogin(
				{password: password, username: username}));
	});
var $author$project$Page$Login$doPasswordReset = function (username) {
	return $elm$core$Platform$Cmd$none;
};
var $author$project$Page$Login$update = F2(
	function (msg, model) {
		var _v0 = _Utils_Tuple2(msg, model.state);
		_v0$10:
		while (true) {
			switch (_v0.a.$) {
				case 'DoLogin':
					if (_v0.b.$ === 'Login') {
						var _v1 = _v0.a;
						var _v2 = _v0.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{state: $author$project$Page$Login$LoggingIn}),
							A2($author$project$Page$Login$doLogin, model.username, model.password));
					} else {
						break _v0$10;
					}
				case 'DoPasswordReset':
					if (_v0.b.$ === 'PasswordReset') {
						var _v3 = _v0.a;
						var _v4 = _v0.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{state: $author$project$Page$Login$ResettingPassword}),
							$author$project$Page$Login$doPasswordReset(model.username));
					} else {
						break _v0$10;
					}
				case 'CheckSessionFailed':
					if (_v0.b.$ === 'CheckingStored') {
						var err = _v0.a.a;
						var _v5 = _v0.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									message: $author$project$Page$Login$Error(err),
									state: $author$project$Page$Login$Login
								}),
							$elm$core$Platform$Cmd$none);
					} else {
						break _v0$10;
					}
				case 'ShowPasswordReset':
					var _v6 = _v0.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{message: $author$project$Page$Login$None, state: $author$project$Page$Login$PasswordReset}),
						$elm$core$Platform$Cmd$none);
				case 'ShowLogin':
					var _v7 = _v0.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{message: $author$project$Page$Login$None, state: $author$project$Page$Login$Login}),
						$elm$core$Platform$Cmd$none);
				case 'LoginCompleted':
					var token = _v0.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								message: $author$project$Page$Login$None,
								state: $author$project$Page$Login$Success(
									{token: token.key, user: token.user})
							}),
						$author$project$Page$Login$doSaveToken(token.key));
				case 'LoginFailed':
					var reason = _v0.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								message: $author$project$Page$Login$Error(reason),
								state: $author$project$Page$Login$Login
							}),
						$elm$core$Platform$Cmd$none);
				case 'CloseMessage':
					var _v8 = _v0.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{message: $author$project$Page$Login$None}),
						$elm$core$Platform$Cmd$none);
				case 'ModelSetUsername':
					var u = _v0.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{username: u}),
						$elm$core$Platform$Cmd$none);
				default:
					var p = _v0.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{password: p}),
						$elm$core$Platform$Cmd$none);
			}
		}
		return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
	});
var $author$project$Main$update = F2(
	function (msg, model) {
		var _v0 = _Utils_Tuple3(msg, model.page, model.layout);
		_v0$7:
		while (true) {
			switch (_v0.a.$) {
				case 'DefaultLayoutMsg':
					if (_v0.c.$ === 'DefaultLayout') {
						var msg_ = _v0.a.a;
						var l = _v0.c.a;
						var _v1 = A2($author$project$Page$DefaultLayout$update, msg_, l);
						var model_ = _v1.a;
						var cmd_ = _v1.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									layout: $author$project$Main$DefaultLayout(model_)
								}),
							A2($elm$core$Platform$Cmd$map, $author$project$Main$DefaultLayoutMsg, cmd_));
					} else {
						break _v0$7;
					}
				case 'UrlRequested':
					var urlRequest = _v0.a.a;
					if (urlRequest.$ === 'Internal') {
						var url = urlRequest.a;
						return _Utils_Tuple2(
							model,
							A2(
								$elm$browser$Browser$Navigation$pushUrl,
								model.key,
								$elm$url$Url$toString(url)));
					} else {
						var href = urlRequest.a;
						return _Utils_Tuple2(
							model,
							$elm$browser$Browser$Navigation$load(href));
					}
				case 'UrlChanged':
					var url = _v0.a.a;
					var _v3 = function () {
						var _v4 = _Utils_Tuple2(
							$author$project$Main$parse_url(url),
							model.token);
						_v4$13:
						while (true) {
							switch (_v4.a.$) {
								case 'UrlNotFound':
									var _v5 = _v4.a;
									return _Utils_Tuple2(
										_Utils_update(
											model,
											{layout: $author$project$Main$NoneLayout, page: $author$project$Main$NotFound}),
										$elm$core$Platform$Cmd$none);
								case 'UrlLogout':
									var _v6 = _v4.a;
									return _Utils_Tuple2(
										_Utils_update(
											model,
											{
												layout: $author$project$Main$NoneLayout,
												page: $author$project$Main$Blank,
												token: $author$project$Util$Left('')
											}),
										$elm$core$Platform$Cmd$batch(
											_List_fromArray(
												[
													A2(
													$elm$core$Platform$Cmd$map,
													$author$project$Main$LoginMsg,
													$author$project$Page$Login$doSaveToken('')),
													A2($elm$browser$Browser$Navigation$pushUrl, model.key, '/login')
												])));
								case 'UrlLogin':
									var _v7 = _v4.a;
									var token = _v4.b;
									var _v8 = $author$project$Page$Login$init(
										A3(
											$author$project$Util$either_map,
											$elm$core$Basics$identity,
											function ($) {
												return $.key;
											},
											token));
									var m = _v8.a;
									var c = _v8.b;
									return _Utils_Tuple2(
										_Utils_update(
											model,
											{
												layout: $author$project$Main$NoneLayout,
												page: $author$project$Main$Login(m)
											}),
										A2($elm$core$Platform$Cmd$map, $author$project$Main$LoginMsg, c));
								case 'UrlMainPage':
									if (_v4.b.$ === 'Right') {
										var _v9 = _v4.a;
										var token = _v4.b.a;
										var _v10 = $author$project$Page$DefaultLayout$init(token.user);
										var layout_ = _v10.a;
										var cmd_ = _v10.b;
										return _Utils_Tuple2(
											_Utils_update(
												model,
												{
													layout: $author$project$Main$DefaultLayout(layout_),
													page: $author$project$Main$MainPage
												}),
											A2($elm$core$Platform$Cmd$map, $author$project$Main$DefaultLayoutMsg, cmd_));
									} else {
										break _v4$13;
									}
								case 'UrlCourse':
									if (_v4.b.$ === 'Right') {
										var id = _v4.a.a;
										var token = _v4.b.a;
										var _v11 = A2($author$project$Page$CoursePage$init, token.key, id);
										var model_ = _v11.a;
										var cmd_2 = _v11.b;
										var _v12 = $author$project$Page$DefaultLayout$init(token.user);
										var layout_ = _v12.a;
										var cmd_1 = _v12.b;
										return _Utils_Tuple2(
											_Utils_update(
												model,
												{
													layout: $author$project$Main$DefaultLayout(layout_),
													page: $author$project$Main$CoursePage(model_)
												}),
											$elm$core$Platform$Cmd$batch(
												_List_fromArray(
													[
														A2($elm$core$Platform$Cmd$map, $author$project$Main$DefaultLayoutMsg, cmd_1),
														A2($elm$core$Platform$Cmd$map, $author$project$Main$CoursePageMsg, cmd_2)
													])));
									} else {
										break _v4$13;
									}
								case 'UrlCourseList':
									if (_v4.b.$ === 'Right') {
										var _v13 = _v4.a;
										var token = _v4.b.a;
										var _v14 = $author$project$Page$CourseListPage$init(token.key);
										var model_ = _v14.a;
										var cmd_2 = _v14.b;
										var _v15 = $author$project$Page$DefaultLayout$init(token.user);
										var layout_ = _v15.a;
										var cmd_1 = _v15.b;
										return _Utils_Tuple2(
											_Utils_update(
												model,
												{
													layout: $author$project$Main$DefaultLayout(layout_),
													page: $author$project$Main$CourseListPage(model_)
												}),
											$elm$core$Platform$Cmd$batch(
												_List_fromArray(
													[
														A2($elm$core$Platform$Cmd$map, $author$project$Main$DefaultLayoutMsg, cmd_1),
														A2($elm$core$Platform$Cmd$map, $author$project$Main$CourseListPageMsg, cmd_2)
													])));
									} else {
										break _v4$13;
									}
								case 'UrlMarksOwn':
									if (_v4.b.$ === 'Right') {
										var _v16 = _v4.a;
										var token = _v4.b.a;
										return _Utils_Tuple2(
											_Utils_update(
												model,
												{page: $author$project$Main$Blank}),
											$elm$core$Platform$Cmd$none);
									} else {
										break _v4$13;
									}
								case 'UrlMarksOfPerson':
									if (_v4.b.$ === 'Right') {
										var string = _v4.a.a;
										var token = _v4.b.a;
										return _Utils_Tuple2(
											_Utils_update(
												model,
												{page: $author$project$Main$Blank}),
											$elm$core$Platform$Cmd$none);
									} else {
										break _v4$13;
									}
								case 'UrlMarksOfCourse':
									if (_v4.b.$ === 'Right') {
										var string = _v4.a.a;
										var token = _v4.b.a;
										return _Utils_Tuple2(
											_Utils_update(
												model,
												{page: $author$project$Main$Blank}),
											$elm$core$Platform$Cmd$none);
									} else {
										break _v4$13;
									}
								case 'UrlProfileOwn':
									if (_v4.b.$ === 'Right') {
										var _v17 = _v4.a;
										var token = _v4.b.a;
										return _Utils_Tuple2(
											_Utils_update(
												model,
												{page: $author$project$Main$Blank}),
											$elm$core$Platform$Cmd$none);
									} else {
										break _v4$13;
									}
								case 'UrlProfileOfUser':
									if (_v4.b.$ === 'Right') {
										var string = _v4.a.a;
										var token = _v4.b.a;
										return _Utils_Tuple2(
											_Utils_update(
												model,
												{page: $author$project$Main$Blank}),
											$elm$core$Platform$Cmd$none);
									} else {
										break _v4$13;
									}
								case 'UrlMessages':
									if (_v4.b.$ === 'Right') {
										var _v18 = _v4.a;
										var token = _v4.b.a;
										return _Utils_Tuple2(
											_Utils_update(
												model,
												{page: $author$project$Main$Blank}),
											$elm$core$Platform$Cmd$none);
									} else {
										break _v4$13;
									}
								default:
									if (_v4.b.$ === 'Right') {
										var _v19 = _v4.a;
										var token = _v4.b.a;
										return _Utils_Tuple2(
											_Utils_update(
												model,
												{page: $author$project$Main$Blank}),
											$elm$core$Platform$Cmd$none);
									} else {
										break _v4$13;
									}
							}
						}
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{page: $author$project$Main$Blank}),
							$elm$core$Platform$Cmd$none);
					}();
					var new_model = _v3.a;
					var cmd = _v3.b;
					return _Utils_Tuple2(
						_Utils_update(
							new_model,
							{
								url: A2($elm$core$Debug$log, 'url changed', url)
							}),
						cmd);
				case 'LoginMsg':
					if (_v0.b.$ === 'Login') {
						if (_v0.a.a.$ === 'LoginCompleted') {
							var msg_ = _v0.a.a;
							var token = msg_.a;
							var model_ = _v0.b.a;
							var _v20 = A2($author$project$Page$Login$update, msg_, model_);
							var m = _v20.a;
							var c = _v20.b;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										page: $author$project$Main$Login(m),
										token: $author$project$Util$Right(token)
									}),
								$elm$core$Platform$Cmd$batch(
									_List_fromArray(
										[
											A2($elm$core$Platform$Cmd$map, $author$project$Main$LoginMsg, c),
											A2($elm$browser$Browser$Navigation$pushUrl, model.key, '/')
										])));
						} else {
							var msg_ = _v0.a.a;
							var model_ = _v0.b.a;
							var _v21 = A2($author$project$Page$Login$update, msg_, model_);
							var m = _v21.a;
							var c = _v21.b;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										page: $author$project$Main$Login(m)
									}),
								A2($elm$core$Platform$Cmd$map, $author$project$Main$LoginMsg, c));
						}
					} else {
						break _v0$7;
					}
				case 'CourseListPageMsg':
					if ((_v0.b.$ === 'CourseListPage') && (_v0.c.$ === 'DefaultLayout')) {
						var msg_ = _v0.a.a;
						var model_ = _v0.b.a;
						var layout_ = _v0.c.a;
						var _v22 = A2($author$project$Page$CourseListPage$update, msg_, model_);
						var model__ = _v22.a;
						var cmd_ = _v22.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									page: $author$project$Main$CourseListPage(model__)
								}),
							A2($elm$core$Platform$Cmd$map, $author$project$Main$CourseListPageMsg, cmd_));
					} else {
						break _v0$7;
					}
				default:
					if ((_v0.b.$ === 'CoursePage') && (_v0.c.$ === 'DefaultLayout')) {
						var msg_ = _v0.a.a;
						var model_ = _v0.b.a;
						var layout_ = _v0.c.a;
						var _v23 = A2($author$project$Page$CoursePage$update, msg_, model_);
						var model__ = _v23.a;
						var cmd_ = _v23.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									page: $author$project$Main$CoursePage(model__)
								}),
							A2($elm$core$Platform$Cmd$map, $author$project$Main$CoursePageMsg, cmd_));
					} else {
						break _v0$7;
					}
			}
		}
		return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
	});
var $author$project$Page$DefaultLayout$SidebarHide = {$: 'SidebarHide'};
var $elm$html$Html$Attributes$stringProperty = F2(
	function (key, string) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$string(string));
	});
var $elm$html$Html$Attributes$class = $elm$html$Html$Attributes$stringProperty('className');
var $elm$html$Html$div = _VirtualDom_node('div');
var $author$project$Page$DefaultLayout$SidebarToggle = {$: 'SidebarToggle'};
var $elm$html$Html$i = _VirtualDom_node('i');
var $elm$html$Html$Attributes$id = $elm$html$Html$Attributes$stringProperty('id');
var $elm$html$Html$span = _VirtualDom_node('span');
var $elm$virtual_dom$VirtualDom$style = _VirtualDom_style;
var $elm$html$Html$Attributes$style = $elm$virtual_dom$VirtualDom$style;
var $author$project$Util$link_span = F2(
	function (attrs, body) {
		return A2(
			$elm$html$Html$span,
			_Utils_ap(
				_List_fromArray(
					[
						A2($elm$html$Html$Attributes$style, 'color', '#4183C4'),
						A2($elm$html$Html$Attributes$style, 'cursor', 'pointer')
					]),
				attrs),
			body);
	});
var $elm$html$Html$a = _VirtualDom_node('a');
var $elm$html$Html$h3 = _VirtualDom_node('h3');
var $elm$html$Html$Attributes$href = function (url) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'href',
		_VirtualDom_noJavaScriptUri(url));
};
var $elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var $elm$html$Html$text = $elm$virtual_dom$VirtualDom$text;
var $author$project$Page$DefaultLayout$logo = function (classes) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('ui middle aligned center aligned column'),
				$elm$html$Html$Attributes$class(classes)
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$a,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$href('/')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$i,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('braille icon large '),
								A2($elm$html$Html$Attributes$style, 'scale', '150%'),
								A2($elm$html$Html$Attributes$style, 'color', '#4183C4'),
								A2($elm$html$Html$Attributes$style, 'margin', '0 0 5px 0')
							]),
						_List_Nil),
						A2(
						$elm$html$Html$h3,
						_List_fromArray(
							[
								A2($elm$html$Html$Attributes$style, 'display', 'inline'),
								A2($elm$html$Html$Attributes$style, 'margin', '0 0 0 20px'),
								A2($elm$html$Html$Attributes$style, 'white-space', 'nowrap'),
								A2($elm$html$Html$Attributes$style, 'color', 'black')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('  Образование ЛНМО')
							]))
					]))
			]));
};
var $elm$virtual_dom$VirtualDom$Normal = function (a) {
	return {$: 'Normal', a: a};
};
var $elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
var $elm$html$Html$Events$on = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$Normal(decoder));
	});
var $elm$html$Html$Events$onClick = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'click',
		$elm$json$Json$Decode$succeed(msg));
};
var $author$project$Page$DefaultLayout$header_mobile = function () {
	var toc = A2(
		$author$project$Util$link_span,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('toc middle aligned center aligned one wide column'),
				$elm$html$Html$Attributes$id('toc'),
				$elm$html$Html$Events$onClick($author$project$Page$DefaultLayout$SidebarToggle)
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$i,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('sidebar icon large')
					]),
				_List_Nil)
			]));
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('ui mobile tablet only grid menu'),
				A2($elm$html$Html$Attributes$style, 'margin-top', '0')
			]),
		_List_fromArray(
			[
				toc,
				$author$project$Page$DefaultLayout$logo('fourteen wide')
			]));
}();
var $author$project$Page$DefaultLayout$menu = function (items) {
	return A2(
		$elm$core$List$map,
		function (_v0) {
			var href = _v0.href;
			var label = _v0.label;
			var icon = _v0.icon;
			return A2(
				$elm$html$Html$a,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('item'),
						$elm$html$Html$Attributes$href(href)
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$i,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class(icon),
								$elm$html$Html$Attributes$class('icon')
							]),
						_List_Nil),
						$elm$html$Html$text(label)
					]));
		},
		items);
};
var $author$project$Page$DefaultLayout$right_menu = function (profile) {
	return _List_fromArray(
		[
			A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('right menu')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('item center aligned raw')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$a,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$href('/profile'),
									A2($elm$html$Html$Attributes$style, 'margin-right', '10px')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$i,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('user icon large')
										]),
									_List_Nil),
									$elm$html$Html$text(profile.name)
								])),
							A2(
							$elm$html$Html$a,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('ui button'),
									$elm$html$Html$Attributes$href('/logout')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('Выйти')
								]))
						]))
				]))
		]);
};
var $author$project$Page$DefaultLayout$make_header_pc = F2(
	function (profile, items) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('ui menu computer only grid')
				]),
			_Utils_ap(
				_List_fromArray(
					[
						$author$project$Page$DefaultLayout$logo('four wide column ui')
					]),
				_Utils_ap(
					$author$project$Page$DefaultLayout$menu(items),
					$author$project$Page$DefaultLayout$right_menu(profile))));
	});
var $elm$virtual_dom$VirtualDom$map = _VirtualDom_map;
var $elm$html$Html$map = $elm$virtual_dom$VirtualDom$map;
var $author$project$Page$DefaultLayout$view = F3(
	function (map_msg, model, html) {
		var mb = $elm$core$Maybe$withDefault('');
		var profile = {
			avatar: '/profile.png',
			name: mb(model.user.firstName) + (' ' + mb(model.user.lastName))
		};
		var items = _List_fromArray(
			[
				{href: '/course', icon: 'book', label: 'Предметы'},
				{href: '/marks', icon: 'chart bar outline', label: 'Оценки'},
				{href: '/messages', icon: 'envelope outline', label: 'Сообщения'}
			]);
		var sidebar = A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					A2(
					$elm$html$Html$Attributes$style,
					'display',
					model.show_sidebar ? 'initial' : 'none'),
					A2($elm$html$Html$Attributes$style, 'position', 'absolute'),
					A2($elm$html$Html$Attributes$style, 'top', '0'),
					A2($elm$html$Html$Attributes$style, 'left', '0'),
					A2($elm$html$Html$Attributes$style, 'z-index', '10'),
					A2($elm$html$Html$Attributes$style, 'width', '100%'),
					A2($elm$html$Html$Attributes$style, 'height', '100%'),
					A2($elm$html$Html$Attributes$style, 'background-color', 'rgba(0,0,0,0.5)'),
					$elm$html$Html$Events$onClick($author$project$Page$DefaultLayout$SidebarHide)
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('ui visible sidebar vertical menu inverted'),
							$elm$html$Html$Attributes$id('sidebar')
						]),
					_Utils_ap(
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('item')
									]),
								_List_Nil)
							]),
						_Utils_ap(
							$author$project$Page$DefaultLayout$menu(items),
							$author$project$Page$DefaultLayout$right_menu(profile))))
				]));
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('ui container')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$map,
					map_msg,
					A2($author$project$Page$DefaultLayout$make_header_pc, profile, items)),
					A2($elm$html$Html$map, map_msg, $author$project$Page$DefaultLayout$header_mobile),
					A2($elm$html$Html$map, map_msg, sidebar),
					html
				]));
	});
var $author$project$Main$viewLayout = F2(
	function (model, body) {
		var _v0 = model.layout;
		if (_v0.$ === 'NoneLayout') {
			return body;
		} else {
			var model_ = _v0.a;
			return A3($author$project$Page$DefaultLayout$view, $author$project$Main$DefaultLayoutMsg, model_, body);
		}
	});
var $author$project$Page$CourseListPage$dictGroupBy = F2(
	function (key, list) {
		var f = F2(
			function (x, acc) {
				return A3(
					$elm$core$Dict$update,
					key(x),
					A2(
						$elm$core$Basics$composeL,
						A2(
							$elm$core$Basics$composeL,
							$elm$core$Maybe$Just,
							$elm$core$Maybe$withDefault(
								_List_fromArray(
									[x]))),
						$elm$core$Maybe$map(
							function (old_list) {
								return A2($elm$core$List$cons, x, old_list);
							})),
					acc);
			});
		return A3($elm$core$List$foldl, f, $elm$core$Dict$empty, list);
	});
var $elm$core$Dict$fromList = function (assocs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, dict) {
				var key = _v0.a;
				var value = _v0.b;
				return A3($elm$core$Dict$insert, key, value, dict);
			}),
		$elm$core$Dict$empty,
		assocs);
};
var $author$project$Page$CourseListPage$groupBy = F2(
	function (group_by, courses) {
		if (group_by.$ === 'GroupByNone') {
			return $elm$core$Dict$fromList(
				_List_fromArray(
					[
						_Utils_Tuple2('', courses)
					]));
		} else {
			var key = function (course) {
				var _v1 = _Utils_Tuple2(
					$author$project$Page$CourseListPage$empty_to_nothing(course.forClass),
					course.forSpecialization);
				if (_v1.a.$ === 'Nothing') {
					var _v2 = _v1.a;
					return 'Остальное';
				} else {
					if (_v1.b.$ === 'Nothing') {
						var _class = _v1.a.a;
						var _v3 = _v1.b;
						return _class;
					} else {
						var _class = _v1.a.a;
						var spec = _v1.b.a;
						return _class + (' (' + (spec.name + ' направление)'));
					}
				}
			};
			return A2($author$project$Page$CourseListPage$dictGroupBy, key, courses);
		}
	});
var $elm$html$Html$h1 = _VirtualDom_node('h1');
var $elm$html$Html$h2 = _VirtualDom_node('h2');
var $elm$html$Html$p = _VirtualDom_node('p');
var $author$project$Page$CourseListPage$viewControls = $elm$html$Html$text('');
var $elm$html$Html$img = _VirtualDom_node('img');
var $elm$html$Html$Attributes$src = function (url) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'src',
		_VirtualDom_noJavaScriptOrHtmlUri(url));
};
var $danyx23$elm_uuid$Uuid$toString = function (_v0) {
	var internalString = _v0.a;
	return internalString;
};
var $author$project$Page$CourseListPage$courseImg = function (mb) {
	if (mb.$ === 'Just') {
		var file = mb.a;
		return A2(
			$elm$html$Html$img,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$src(
					'/file/' + (A2(
						$elm$core$Maybe$withDefault,
						'',
						A2($elm$core$Maybe$map, $danyx23$elm_uuid$Uuid$toString, file.id)) + '/download'))
				]),
			_List_Nil);
	} else {
		return A2(
			$elm$html$Html$img,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$src('/img/course.jpg')
				]),
			_List_Nil);
	}
};
var $author$project$Page$CourseListPage$viewCourse = function (course) {
	return A2(
		$elm$html$Html$a,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('card'),
				$elm$html$Html$Attributes$href(
				A2(
					$elm$core$Maybe$withDefault,
					'',
					A2(
						$elm$core$Maybe$map,
						function (id) {
							return '/course/' + $danyx23$elm_uuid$Uuid$toString(id);
						},
						course.id)))
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('image')
					]),
				_List_fromArray(
					[
						$author$project$Page$CourseListPage$courseImg(course.logo)
					])),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('content')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('header')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text(course.title)
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('meta')
							]),
						_List_Nil),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('description')
							]),
						_List_Nil)
					])),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('extra content')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$span,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('')
							]),
						A2(
							$elm$core$Maybe$withDefault,
							_List_Nil,
							A2(
								$elm$core$Maybe$map,
								function (c) {
									return _List_fromArray(
										[
											A2(
											$elm$html$Html$i,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('users icon')
												]),
											_List_Nil),
											$elm$html$Html$text(c + ' класс')
										]);
								},
								course.forClass))),
						A2(
						$elm$html$Html$span,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('right floated')
							]),
						A2(
							$elm$core$Maybe$withDefault,
							_List_Nil,
							A2(
								$elm$core$Maybe$map,
								function (g) {
									return _List_fromArray(
										[
											A2(
											$elm$html$Html$i,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('list ol icon')
												]),
											_List_Nil),
											$elm$html$Html$text(g)
										]);
								},
								course.forGroup)))
					]))
			]));
};
var $author$project$Page$CourseListPage$view = function (model) {
	var view_courses = function (cs) {
		return _List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('ui link cards')
					]),
				A2($elm$core$List$map, $author$project$Page$CourseListPage$viewCourse, cs))
			]);
	};
	var body = function () {
		var _v0 = model.state;
		switch (_v0.$) {
			case 'Completed':
				if (!_v0.a.b) {
					return _List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('row center-xs')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$h2,
									_List_Nil,
									_List_fromArray(
										[
											$elm$html$Html$text('У вас нет курсов')
										]))
								]))
						]);
				} else {
					var courses = _v0.a;
					var _v1 = model.group_by;
					if (_v1.$ === 'GroupByNone') {
						return view_courses(courses);
					} else {
						var grouped = A2($author$project$Page$CourseListPage$groupBy, model.group_by, courses);
						return $elm$core$List$concat(
							A2(
								$elm$core$List$map,
								function (_v2) {
									var g = _v2.a;
									var cs = _v2.b;
									return _Utils_ap(
										_List_fromArray(
											[
												A2(
												$elm$html$Html$h2,
												_List_Nil,
												_List_fromArray(
													[
														$elm$html$Html$text(g)
													]))
											]),
										view_courses(cs));
								},
								$elm$core$Dict$toList(grouped)));
					}
				}
			case 'Error':
				var err = _v0.a;
				return _List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('ui negative message')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('header')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('Ошибка при попытке получения списка предметов')
									])),
								A2(
								$elm$html$Html$p,
								_List_Nil,
								_List_fromArray(
									[
										$elm$html$Html$text(err)
									]))
							]))
					]);
			default:
				return _List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('ui message')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('ui active inline loader small'),
										A2($elm$html$Html$Attributes$style, 'margin-right', '1em')
									]),
								_List_Nil),
								$elm$html$Html$text('Загружаем список предметов')
							]))
					]);
		}
	}();
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_Utils_ap(
			_List_fromArray(
				[
					A2(
					$elm$html$Html$h1,
					_List_Nil,
					_List_fromArray(
						[
							$elm$html$Html$text('Ваши предметы')
						])),
					$author$project$Page$CourseListPage$viewControls
				]),
			body));
};
var $author$project$Page$CoursePage$showFetchResult = function (fetchResult) {
	if (fetchResult.$ === 'ResCourse') {
		var courseRead = fetchResult.a;
		return courseRead.title;
	} else {
		var activities = fetchResult.a;
		return 'Активностей: ' + $elm$core$String$fromInt(
			$elm$core$List$length(activities));
	}
};
var $author$project$Component$MultiTask$viewTask = F3(
	function (show_result, show_error, _v0) {
		var label = _v0.a;
		var s = _v0.b;
		var item = F2(
			function (icon, t) {
				return A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('item')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('content')
								]),
							_List_fromArray(
								[
									icon,
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('header')
										]),
									_List_fromArray(
										[
											$elm$html$Html$text(label)
										])),
									$elm$html$Html$text(t)
								]))
						]));
			});
		switch (s.$) {
			case 'Running':
				return A3(
					$elm$core$Basics$apL,
					item,
					A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('ui active inline loader small'),
								A2($elm$html$Html$Attributes$style, 'margin-right', '1em')
							]),
						_List_Nil),
					'');
			case 'Complete':
				var res = s.a;
				return A2(
					item,
					A2(
						$elm$html$Html$i,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('check icon'),
								A2($elm$html$Html$Attributes$style, 'margin-right', '1em'),
								A2($elm$html$Html$Attributes$style, 'color', 'green')
							]),
						_List_Nil),
					show_result(res));
			default:
				var err = s.a;
				return A2(
					item,
					A2(
						$elm$html$Html$i,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('exclamation icon'),
								A2($elm$html$Html$Attributes$style, 'margin-right', '1em'),
								A2($elm$html$Html$Attributes$style, 'color', 'green')
							]),
						_List_Nil),
					show_error(err));
		}
	});
var $author$project$Component$MultiTask$view = F3(
	function (show_result, show_error, model) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('ui segment ')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('ui relaxed divided list')
						]),
					$elm$core$Array$toList(
						A2(
							$elm$core$Array$map,
							A2($author$project$Component$MultiTask$viewTask, show_result, show_error),
							model.task_states)))
				]));
	});
var $author$project$Page$CoursePage$view = function (model) {
	var _v0 = model.state;
	switch (_v0.$) {
		case 'Fetching':
			var model_ = _v0.a;
			var fetcher = A3($author$project$Component$MultiTask$view, $author$project$Page$CoursePage$showFetchResult, $author$project$Util$httpErrorToString, model_);
			return A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('ui text container')
					]),
				_List_fromArray(
					[
						A2($elm$html$Html$map, $author$project$Page$CoursePage$MsgFetch, fetcher)
					]));
		case 'FetchDone':
			var courseRead = _v0.a;
			var activities = _v0.b;
			return $elm$html$Html$text('Done');
		default:
			var err = _v0.a;
			return $elm$html$Html$text('Failed' + err);
	}
};
var $author$project$Page$Login$CloseMessage = {$: 'CloseMessage'};
var $author$project$Page$Login$DoLogin = {$: 'DoLogin'};
var $author$project$Page$Login$DoPasswordReset = {$: 'DoPasswordReset'};
var $author$project$Page$Login$ModelSetPassword = function (a) {
	return {$: 'ModelSetPassword', a: a};
};
var $author$project$Page$Login$ModelSetUsername = function (a) {
	return {$: 'ModelSetUsername', a: a};
};
var $author$project$Page$Login$ShowPasswordReset = {$: 'ShowPasswordReset'};
var $elm$html$Html$form = _VirtualDom_node('form');
var $elm$html$Html$Events$alwaysPreventDefault = function (msg) {
	return _Utils_Tuple2(msg, true);
};
var $elm$virtual_dom$VirtualDom$MayPreventDefault = function (a) {
	return {$: 'MayPreventDefault', a: a};
};
var $elm$html$Html$Events$preventDefaultOn = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$MayPreventDefault(decoder));
	});
var $elm$html$Html$Events$onSubmit = function (msg) {
	return A2(
		$elm$html$Html$Events$preventDefaultOn,
		'submit',
		A2(
			$elm$json$Json$Decode$map,
			$elm$html$Html$Events$alwaysPreventDefault,
			$elm$json$Json$Decode$succeed(msg)));
};
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $elm$core$Tuple$second = function (_v0) {
	var y = _v0.b;
	return y;
};
var $elm$html$Html$Attributes$classList = function (classes) {
	return $elm$html$Html$Attributes$class(
		A2(
			$elm$core$String$join,
			' ',
			A2(
				$elm$core$List$map,
				$elm$core$Tuple$first,
				A2($elm$core$List$filter, $elm$core$Tuple$second, classes))));
};
var $elm$html$Html$input = _VirtualDom_node('input');
var $elm$html$Html$Events$alwaysStop = function (x) {
	return _Utils_Tuple2(x, true);
};
var $elm$virtual_dom$VirtualDom$MayStopPropagation = function (a) {
	return {$: 'MayStopPropagation', a: a};
};
var $elm$html$Html$Events$stopPropagationOn = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$MayStopPropagation(decoder));
	});
var $elm$json$Json$Decode$at = F2(
	function (fields, decoder) {
		return A3($elm$core$List$foldr, $elm$json$Json$Decode$field, decoder, fields);
	});
var $elm$html$Html$Events$targetValue = A2(
	$elm$json$Json$Decode$at,
	_List_fromArray(
		['target', 'value']),
	$elm$json$Json$Decode$string);
var $elm$html$Html$Events$onInput = function (tagger) {
	return A2(
		$elm$html$Html$Events$stopPropagationOn,
		'input',
		A2(
			$elm$json$Json$Decode$map,
			$elm$html$Html$Events$alwaysStop,
			A2($elm$json$Json$Decode$map, tagger, $elm$html$Html$Events$targetValue)));
};
var $elm$html$Html$Attributes$placeholder = $elm$html$Html$Attributes$stringProperty('placeholder');
var $elm$html$Html$Attributes$type_ = $elm$html$Html$Attributes$stringProperty('type');
var $elm$html$Html$Attributes$value = $elm$html$Html$Attributes$stringProperty('value');
var $author$project$Page$Login$viewField = F5(
	function (field_type, value_, placeholder_, icon, on_input) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('field')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('ui left icon input')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$i,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$classList(
									_List_fromArray(
										[
											_Utils_Tuple2(icon, true),
											_Utils_Tuple2('icon', true)
										]))
								]),
							_List_Nil),
							A2(
							$elm$html$Html$input,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$type_(field_type),
									$elm$html$Html$Attributes$value(value_),
									$elm$html$Html$Attributes$placeholder(placeholder_),
									$elm$html$Html$Events$onInput(on_input)
								]),
							_List_Nil)
						]))
				]));
	});
var $author$project$Page$Login$view = function (model) {
	var pw_reset = A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('ui message')
			]),
		_List_fromArray(
			[
				$elm$html$Html$text('Забыли пароль?  '),
				A2(
				$author$project$Util$link_span,
				_List_fromArray(
					[
						$elm$html$Html$Events$onClick($author$project$Page$Login$ShowPasswordReset)
					]),
				_List_fromArray(
					[
						$elm$html$Html$text('Восстановите')
					])),
				$elm$html$Html$text(' его.')
			]));
	var progress = function (txt) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('ui message')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('ui active inline loader small')
						]),
					_List_Nil),
					$elm$html$Html$text('  ' + txt)
				]));
	};
	var msg = function (m) {
		switch (m.$) {
			case 'None':
				return $elm$html$Html$text('');
			case 'Info':
				var s = m.a;
				return A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('ui message')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$i,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('close icon'),
									$elm$html$Html$Events$onClick($author$project$Page$Login$CloseMessage)
								]),
							_List_Nil),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('header')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('Ошибка входа')
								])),
							A2(
							$elm$html$Html$p,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text(s)
								]))
						]));
			default:
				var s = m.a;
				return A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('ui negative message')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$i,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('close icon'),
									$elm$html$Html$Events$onClick($author$project$Page$Login$CloseMessage)
								]),
							_List_Nil),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('header')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('Ошибка входа')
								])),
							A2(
							$elm$html$Html$p,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text(s)
								]))
						]));
		}
	};
	var blue_button = F2(
		function (label, on_click) {
			return A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('ui fluid large blue submit button'),
						$elm$html$Html$Events$onClick(on_click)
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(label)
					]));
		});
	var back_to_login = A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('ui message')
			]),
		_List_fromArray(
			[
				A2(
				$author$project$Util$link_span,
				_List_fromArray(
					[
						$elm$html$Html$Events$onClick($author$project$Page$Login$ShowLogin)
					]),
				_List_fromArray(
					[
						$elm$html$Html$text('Назад')
					])),
				$elm$html$Html$text(' к форме входа.')
			]));
	var form = function () {
		var _v0 = model.state;
		switch (_v0.$) {
			case 'Login':
				return A2(
					$elm$html$Html$div,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$form,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('ui large form'),
									$elm$html$Html$Events$onSubmit($author$project$Page$Login$DoLogin)
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('ui stacked segment')
										]),
									_List_fromArray(
										[
											A5($author$project$Page$Login$viewField, 'text', model.username, 'Логин', 'user', $author$project$Page$Login$ModelSetUsername),
											A5($author$project$Page$Login$viewField, 'password', model.password, 'Пароль', 'lock', $author$project$Page$Login$ModelSetPassword),
											A2(blue_button, 'Войти', $author$project$Page$Login$DoLogin)
										]))
								])),
							pw_reset
						]));
			case 'PasswordReset':
				return A2(
					$elm$html$Html$div,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$form,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('ui large form'),
									$elm$html$Html$Events$onSubmit($author$project$Page$Login$DoPasswordReset)
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('ui stacked segment')
										]),
									_List_fromArray(
										[
											A5($author$project$Page$Login$viewField, 'text', model.username, 'Логин', 'user', $author$project$Page$Login$ModelSetUsername),
											A2(blue_button, 'Восстановить', $author$project$Page$Login$DoPasswordReset)
										]))
								])),
							back_to_login
						]));
			case 'Success':
				var token = _v0.a.token;
				var user = _v0.a.user;
				var a = 'Аноним';
				var nm = function () {
					var _v1 = user.firstName;
					if (_v1.$ === 'Nothing') {
						return a;
					} else {
						if (_v1.a === '') {
							return a;
						} else {
							var x = _v1.a;
							return x;
						}
					}
				}();
				return A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('ui message')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text('Привет, ' + nm)
						]));
			case 'CheckingStored':
				return progress('Проверяем текущую сессию');
			case 'LoggingIn':
				return progress('Выполняется вход');
			default:
				return progress('Выполняется сброс пароля');
		}
	}();
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('row center-xs middle-xs'),
				A2($elm$html$Html$Attributes$style, 'height', '100%'),
				A2($elm$html$Html$Attributes$style, 'background-color', '#EEE')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('col-4')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('box'),
								A2($elm$html$Html$Attributes$style, 'width', '400px')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$h2,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('ui blue image header')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$div,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('content')
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Вход в систему')
											]))
									])),
								form,
								msg(model.message)
							]))
					]))
			]));
};
var $author$project$Page$NotFound$view = A2(
	$elm$html$Html$div,
	_List_fromArray(
		[
			$elm$html$Html$Attributes$class('ui middle aligned center aligned grid'),
			A2($elm$html$Html$Attributes$style, 'height', '100%'),
			A2($elm$html$Html$Attributes$style, 'background-color', '#EEE')
		]),
	_List_fromArray(
		[
			A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('column')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$h1,
					_List_Nil,
					_List_fromArray(
						[
							$elm$html$Html$text('Страница не найдена')
						])),
					A2(
					$elm$html$Html$a,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('ui large blue submit button'),
							$elm$html$Html$Attributes$href('/')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text('На главную')
						]))
				]))
		]));
var $author$project$Main$viewPage = function (model) {
	var _v0 = model.page;
	switch (_v0.$) {
		case 'Login':
			var m = _v0.a;
			return A2(
				$elm$html$Html$map,
				$author$project$Main$LoginMsg,
				$author$project$Page$Login$view(m));
		case 'MainPage':
			return $elm$html$Html$text('MainPage');
		case 'CourseListPage':
			var model_ = _v0.a;
			return A2(
				$elm$html$Html$map,
				$author$project$Main$CourseListPageMsg,
				$author$project$Page$CourseListPage$view(model_));
		case 'CoursePage':
			var model_ = _v0.a;
			return A2(
				$elm$html$Html$map,
				$author$project$Main$CoursePageMsg,
				$author$project$Page$CoursePage$view(model_));
		case 'NotFound':
			return $author$project$Page$NotFound$view;
		default:
			return $elm$html$Html$text('');
	}
};
var $author$project$Main$view = function (model) {
	return {
		body: _List_fromArray(
			[
				A2(
				$author$project$Main$viewLayout,
				model,
				$author$project$Main$viewPage(model))
			]),
		title: 'ЛНМО | Образовательный портал'
	};
};
var $author$project$Main$main = $elm$browser$Browser$application(
	{init: $author$project$Main$init, onUrlChange: $author$project$Main$UrlChanged, onUrlRequest: $author$project$Main$UrlRequested, subscriptions: $author$project$Main$subscriptions, update: $author$project$Main$update, view: $author$project$Main$view});
_Platform_export({'Main':{'init':$author$project$Main$main(
	A2(
		$elm$json$Json$Decode$andThen,
		function (token) {
			return $elm$json$Json$Decode$succeed(
				{token: token});
		},
		A2($elm$json$Json$Decode$field, 'token', $elm$json$Json$Decode$string)))(0)}});}(this));
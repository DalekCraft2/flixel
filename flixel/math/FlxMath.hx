package flixel.math;

import flixel.FlxG;
import flixel.FlxSprite;
import openfl.geom.Rectangle;
#if FLX_TOUCH
import flixel.input.touch.FlxTouch;
#end

/**
 * A class containing a set of math-related functions.
 */
class FlxMath
{
	#if (flash || js || ios || blackberry)
	/**
	 * Minimum value of a floating-point number.
	 */
	public static inline var MIN_VALUE_FLOAT:Float = 0.0000000000000001;
	#else

	/**
	 * Minimum value of a floating-point number.
	 */
	public static inline var MIN_VALUE_FLOAT:Float = 5e-324;
	#end

	/**
	 * Maximum value of a floating-point number.
	 */
	public static inline var MAX_VALUE_FLOAT:Float = 1.79e+308;

	/**
	 * Minimum value of an integer.
	 */
	public static inline var MIN_VALUE_INT:Int = -MAX_VALUE_INT;

	/**
	 * Maximum value of an integer.
	 */
	public static inline var MAX_VALUE_INT:Int = 0x7FFFFFFF;

	/**
	 * Approximation of `Math.sqrt(2)`.
	 */
	public static inline var SQUARE_ROOT_OF_TWO:Float = 1.41421356237;

	/**
	 * Used to account for floating-point inaccuracies.
	 */
	public static inline var EPSILON:Float = 0.0000001;

	/**
	 * Rounds a decimal number to have reduced precision (fewer decimal numbers).
	 *
	 * ```haxe
	 * roundDecimal(1.2485, 2) = 1.25
	 * ```
	 *
	 * @param Value Any number.
	 * @param Precision Number of decimals the result should have.
	 * @return The rounded value of that number.
	 */
	public static function roundDecimal(Value:Float, Precision:Int):Float
	{
		var mult:Float = 1;
		for (i in 0...Precision)
		{
			mult *= 10;
		}
		return Math.fround(Value * mult) / mult;
	}

	/**
	 * Bounds a number by a minimum and maximum. Ensures that this number is
	 * no smaller than the minimum, and no larger than the maximum.
	 * Leaving a bound `null` means that side is unbounded.
	 *
	 * @param Value Any number.
	 * @param Min Lower bound of range.
	 * @param Max Upper bound of range.
	 * @return The bounded value of the number.
	 */
	public static inline function bound(Value:Float, ?Min:Float, ?Max:Float):Float
	{
		var lowerBound:Float = (Min != null && Value < Min) ? Min : Value;
		return (Max != null && lowerBound > Max) ? Max : lowerBound;
	}

	/**
	 * Returns the linear interpolation of two numbers if `ratio`
	 * is between `0` and `1`, and the linear extrapolation otherwise.
	 *
	 * Examples:
	 *
	 * ```haxe
	 * lerp(a, b, 0) = a
	 * lerp(a, b, 1) = b
	 * lerp(5, 15, 0.5) = 10
	 * lerp(5, 15, -1) = -5
	 * ```
	 */
	public static inline function lerp(a:Float, b:Float, ratio:Float):Float
	{
		return a + ratio * (b - a);
	}

	/**
	 * Checks whether a number is in defined range. A `null` bound means that side is unbounded.
	 *
	 * @param Value Number to check.
	 * @param Min Lower bound of range.
	 * @param Max Higher bound of range.
	 * @return Whether `Value` is in the range.
	 */
	public static inline function inBounds(Value:Float, Min:Null<Float>, Max:Null<Float>):Bool
	{
		return (Min == null || Value >= Min) && (Max == null || Value <= Max);
	}

	/**
	 * Checks whether the given number is odd.
	 */
	public static inline function isOdd(n:Float):Bool
	{
		return (Std.int(n) & 1) != 0;
	}

	/**
	 * Checks whether the given number is even.
	 */
	public static inline function isEven(n:Float):Bool
	{
		return (Std.int(n) & 1) == 0;
	}

	/**
	 * Compares two numbers.
	 * 
	 * @return `-1` if `a < b`, `1` if `b > a`, and `0` if `a == b`.
	 */
	public static function numericComparison(a:Float, b:Float):Int
	{
		if (b > a)
		{
			return -1;
		}
		else if (a > b)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Checks whether the given x-/y-coordinate is within the given rectangular block.
	 *
	 * @param pointX The x-value to test.
	 * @param pointY The y-value to test.
	 * @param rectX The x-value of the region to test within.
	 * @param rectY The y-value of the region to test within.
	 * @param rectWidth The width of the region to test within.
	 * @param rectHeight The height of the region to test within.
	 *
	 * @return Whether `pointX`/`pointY` is within the region.
	 */
	public static function pointInCoordinates(pointX:Float, pointY:Float, rectX:Float, rectY:Float, rectWidth:Float, rectHeight:Float):Bool
	{
		if (pointX >= rectX && pointX <= (rectX + rectWidth))
		{
			if (pointY >= rectY && pointY <= (rectY + rectHeight))
			{
				return true;
			}
		}
		return false;
	}

	/**
	 * Checks whether the given x-/y-coordinate is within the given rectangular block.
	 *
	 * @param pointX The x-value to test.
	 * @param pointY The y-value to test.
	 * @param rect The `FlxRect` to test within.
	 * @return Whether `pointX`/`pointY` is within `rect`.
	 */
	public static function pointInFlxRect(pointX:Float, pointY:Float, rect:FlxRect):Bool
	{
		return pointX >= rect.x && pointX <= rect.right && pointY >= rect.y && pointY <= rect.bottom;
	}

	#if FLX_MOUSE
	/**
	 * Checks whether the mouse world x-/y-coordinate is within the given rectangular block.
	 *
	 * @param useWorldCoords Whether to use the world x/y-coordinates of the mouse instead of the screen x-/y-coordinates.
	 * @param rect The `FlxRect` to test within. If this is `null` for any reason, this function always returns `true`.
	 * @return Whether the mouse is within `rect`.
	 */
	public static function mouseInFlxRect(useWorldCoords:Bool, rect:FlxRect):Bool
	{
		if (rect == null)
		{
			return true;
		}

		if (useWorldCoords)
		{
			return pointInFlxRect(Math.floor(FlxG.mouse.x), Math.floor(FlxG.mouse.y), rect);
		}
		else
		{
			return pointInFlxRect(FlxG.mouse.screenX, FlxG.mouse.screenY, rect);
		}
	}
	#end

	/**
	 * Checks whether the given x-/y-coordinate is within the given `Rectangle`.
	 *
	 * @param pointX The x-value to test.
	 * @param pointY The y-value to test.
	 * @param rect The `Rectangle` to test within.
	 * @return Whether `pointX`/`pointY` is within `rect`.
	 */
	public static function pointInRectangle(pointX:Float, pointY:Float, rect:Rectangle):Bool
	{
		return pointX >= rect.x && pointX <= rect.right && pointY >= rect.y && pointY <= rect.bottom;
	}

	/**
	 * Adds the given amount to the value, but never lets the value
	 * go over the specified maximum or under the specified minimum.
	 *
	 * @param value The value to add the amount to.
	 * @param amount The amount to add to the value.
	 * @param max The maximum the value is allowed to be.
	 * @param min The minimum the value is allowed to be.
	 * @return The bounded value.
	 */
	public static function maxAdd(value:Int, amount:Int, max:Int, min:Int = 0):Int
	{
		value += amount;

		if (value > max)
		{
			value = max;
		}
		else if (value <= min)
		{
			value = min;
		}

		return value;
	}

	/**
	 * Makes sure that value always stays between `min` and `max`,
	 * by wrapping the value around.
	 *
	 * @param value The value to wrap around.
	 * @param min The minimum the value is allowed to be.
	 * @param max The maximum the value is allowed to be.
	 * @return The wrapped value.
	 */
	public static function wrap(value:Int, min:Int, max:Int):Int
	{
		var range:Int = max - min + 1;

		if (value < min)
			value += range * Std.int((min - value) / range + 1);

		return min + (value - min) % range;
	}

	/**
	 * Remaps a number from one range to another.
	 *
	 * @param value The incoming value to be converted.
	 * @param start1 Lower bound of the value's current range.
	 * @param stop1 Upper bound of the value's current range.
	 * @param start2 Lower bound of the value's target range.
	 * @param stop2 Upper bound of the value's target range.
	 * @return The remapped value.
	 */
	public static function remapToRange(value:Float, start1:Float, stop1:Float, start2:Float, stop2:Float):Float
	{
		return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1));
	}

	/**
	 * Finds the dot product value of two vectors.
	 *
	 * @param ax First vector's x-coordinate.
	 * @param ay First vector's y-coordinate.
	 * @param bx Second vector's x-coordinate.
	 * @param by Second vector's y-coordinate.
	 * @return Result of the dot product.
	 */
	public static inline function dotProduct(ax:Float, ay:Float, bx:Float, by:Float):Float
	{
		return ax * bx + ay * by;
	}

	/**
	 * Returns the length of the given vector.
	 */
	public static inline function vectorLength(dx:Float, dy:Float):Float
	{
		return Math.sqrt(dx * dx + dy * dy);
	}

	/**
	 * Finds the distance (in pixels, rounded) between two `FlxSprite`s, taking their origins into account.
	 *
	 * @param SpriteA The first `FlxSprite`.
	 * @param SpriteB The second `FlxSprite`.
	 * @return Distance between the sprites in pixels.
	 */
	public static inline function distanceBetween(SpriteA:FlxSprite, SpriteB:FlxSprite):Int
	{
		var dx:Float = (SpriteA.x + SpriteA.origin.x) - (SpriteB.x + SpriteB.origin.x);
		var dy:Float = (SpriteA.y + SpriteA.origin.y) - (SpriteB.y + SpriteB.origin.y);
		return Std.int(FlxMath.vectorLength(dx, dy));
	}

	/**
	 * Checks whether the distance between two `FlxSprite`s is within a specified number.
	 * A faster algorithm than `distanceBetween()` because `Math.sqrt()` is avoided.
	 *
	 * @param SpriteA The first `FlxSprite`.
	 * @param SpriteB The second `FlxSprite`.
	 * @param Distance The distance to check.
	 * @param IncludeEqual Whether to return `true` if the calculated distance is equal to the given `Distance`.
	 * @return Whether the distance between the sprites is less than the given `Distance`.
	 */
	public static inline function isDistanceWithin(SpriteA:FlxSprite, SpriteB:FlxSprite, Distance:Float, IncludeEqual:Bool = false):Bool
	{
		var dx:Float = (SpriteA.x + SpriteA.origin.x) - (SpriteB.x + SpriteB.origin.x);
		var dy:Float = (SpriteA.y + SpriteA.origin.y) - (SpriteB.y + SpriteB.origin.y);

		if (IncludeEqual)
			return dx * dx + dy * dy <= Distance * Distance;
		else
			return dx * dx + dy * dy < Distance * Distance;
	}

	/**
	 * Finds the distance (in pixels, rounded) from an `FlxSprite`
	 * to the given `FlxPoint`, taking the source origin into account.
	 *
	 * @param Sprite The `FlxSprite`.
	 * @param Target The `FlxPoint`.
	 * @return Distance in pixels.
	 */
	public static inline function distanceToPoint(Sprite:FlxSprite, Target:FlxPoint):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - Target.x;
		var dy:Float = (Sprite.y + Sprite.origin.y) - Target.y;
		Target.putWeak();
		return Std.int(FlxMath.vectorLength(dx, dy));
	}

	/**
	 * Checks whether the distance from an `FlxSprite` to the given
	 * `FlxPoint` is within a specified number.
	 * A faster algorithm than `distanceToPoint()` because `Math.sqrt()` is avoided.
	 *
	 * @param Sprite The `FlxSprite`.
	 * @param Target The `FlxPoint`.
	 * @param Distance The distance to check.
	 * @param IncludeEqual Whether to return `true` if the calculated distance is equal to the given `Distance`.
	 * @return Whether the distance between the sprite and the point is less than the given `Distance`.
	 */
	public static inline function isDistanceToPointWithin(Sprite:FlxSprite, Target:FlxPoint, Distance:Float, IncludeEqual:Bool = false):Bool
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - (Target.x);
		var dy:Float = (Sprite.y + Sprite.origin.y) - (Target.y);

		Target.putWeak();

		if (IncludeEqual)
			return dx * dx + dy * dy <= Distance * Distance;
		else
			return dx * dx + dy * dy < Distance * Distance;
	}

	#if FLX_MOUSE
	/**
	 * Finds the distance (in pixels, rounded) from the object's position to the mouse's position.
	 *
	 * @param Sprite The `FlxSprite` to test against.
	 * @return The distance between the given sprite and the mouse.
	 */
	public static inline function distanceToMouse(Sprite:FlxSprite):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - FlxG.mouse.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - FlxG.mouse.screenY;
		return Std.int(FlxMath.vectorLength(dx, dy));
	}

	/**
	 * Checks whether the distance from the object's position to the mouse's position is within a specified number.
	 * A faster algorithm than `distanceToMouse()` because `Math.sqrt()` is avoided.
	 *
	 * @param Sprite The `FlxSprite` to test against.
	 * @param Distance The distance to check.
	 * @param IncludeEqual Whether to return `true` if the calculated distance is equal to the given `Distance`.
	 * @return Whether the distance between the sprite and the mouse is less than the given `Distance`.
	 */
	public static inline function isDistanceToMouseWithin(Sprite:FlxSprite, Distance:Float, IncludeEqual:Bool = false):Bool
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - FlxG.mouse.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - FlxG.mouse.screenY;

		if (IncludeEqual)
			return dx * dx + dy * dy <= Distance * Distance;
		else
			return dx * dx + dy * dy < Distance * Distance;
	}
	#end

	#if FLX_TOUCH
	/**
	 * Finds the distance (in pixels, rounded) from the object's position to the `FlxPoint` screen position.
	 *
	 * @param Sprite The `FlxSprite` to test against.
	 * @param Touch The `FlxTouch` to test against.
	 * @return The distance between the given sprite and the touch coordinates.
	 */
	public static inline function distanceToTouch(Sprite:FlxSprite, Touch:FlxTouch):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - Touch.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - Touch.screenY;
		return Std.int(FlxMath.vectorLength(dx, dy));
	}

	/**
	 * Checks whether the distance from the object's position to the `FlxPoint` screen position is within a specified number.
	 * A faster algorithm than `distanceToTouch()` because `Math.sqrt()` is avoided.
	 *
	 * @param Sprite The `FlxSprite` to test against.
	 * @param Distance The distance to check.
	 * @param IncludeEqual Whether to return `true` if the calculated distance is equal to the given `Distance`.
	 * @return Whether the distance between the sprite and the touch is less than the given `Distance`.
	 */
	public static inline function isDistanceToTouchWithin(Sprite:FlxSprite, Touch:FlxTouch, Distance:Float, IncludeEqual:Bool = false):Bool
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - Touch.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - Touch.screenY;

		if (IncludeEqual)
			return dx * dx + dy * dy <= Distance * Distance;
		else
			return dx * dx + dy * dy < Distance * Distance;
	}
	#end

	/**
	 * Returns the amount of decimals a `Float` has.
	 */
	public static function getDecimals(n:Float):Int
	{
		var helperArray:Array<String> = Std.string(n).split(".");
		var decimals:Int = 0;

		if (helperArray.length > 1)
		{
			decimals = helperArray[1].length;
		}

		return decimals;
	}

	public static inline function equal(aValueA:Float, aValueB:Float, aDiff:Float = EPSILON):Bool
	{
		return Math.abs(aValueA - aValueB) <= aDiff;
	}

	/**
	 * Gets the sign of a number.
	 * 
	 * @return `-1` if `n < 0` and `1` if `n >= 0`.
	 */
	public static inline function signOf(n:Float):Int
	{
		return (n < 0) ? -1 : 1;
	}

	/**
	 * Checks whether two numbers have the same sign (using `FlxMath.signOf()`).
	 */
	public static inline function sameSign(a:Float, b:Float):Bool
	{
		return signOf(a) == signOf(b);
	}

	/**
	 * A faster but slightly less accurate version of `Math.sin()`.
	 * About 2-6 times faster with < 0.05% average error.
	 *
	 * @param n The angle in radians.
	 * @return An approximated sine of `n`.
	 */
	public static inline function fastSin(n:Float):Float
	{
		n *= 0.3183098862; // divide by pi to normalize

		// bound between -1 and 1
		if (n > 1)
		{
			n -= (Math.ceil(n) >> 1) << 1;
		}
		else if (n < -1)
		{
			n += (Math.ceil(-n) >> 1) << 1;
		}

		// this approx only works for -pi <= rads <= pi, but it's quite accurate in this region
		if (n > 0)
		{
			return n * (3.1 + n * (0.5 + n * (-7.2 + n * 3.6)));
		}
		else
		{
			return n * (3.1 - n * (0.5 + n * (7.2 + n * 3.6)));
		}
	}

	/**
	 * A faster, but slightly less accurate version of `Math.cos()`.
	 * About 2-6 times faster with < 0.05% average error.
	 *
	 * @param n The angle in radians.
	 * @return An approximated cosine of `n`.
	 */
	public static inline function fastCos(n:Float):Float
	{
		return fastSin(n + 1.570796327); // sin and cos are the same, offset by pi/2
	}

	/**
	 * Hyperbolic sine.
	 */
	public static inline function sinh(n:Float):Float
	{
		return (Math.exp(n) - Math.exp(-n)) / 2;
	}

	/**
	 * Returns the larger argument.
	 */
	public static inline function maxInt(a:Int, b:Int):Int
	{
		return (a > b) ? a : b;
	}

	/**
	 * Returns the smaller argument.
	 */
	public static inline function minInt(a:Int, b:Int):Int
	{
		return (a > b) ? b : a;
	}

	/**
	 * Returns the absolute integer value.
	 */
	public static inline function absInt(n:Int):Int
	{
		return (n > 0) ? n : -n;
	}
}

package flixel.util;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tile.FlxTileblock;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

/**
 * `FlxCollision`
 *
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 */
class FlxCollision
{
	// Optimization: Local static vars to reduce allocations
	static var pointA:FlxPoint = new FlxPoint();
	static var pointB:FlxPoint = new FlxPoint();
	static var centerA:FlxPoint = new FlxPoint();
	static var centerB:FlxPoint = new FlxPoint();
	static var matrixA:FlxMatrix = new FlxMatrix();
	static var matrixB:FlxMatrix = new FlxMatrix();
	static var testMatrix:FlxMatrix = new FlxMatrix();
	static var boundsA:FlxRect = new FlxRect();
	static var boundsB:FlxRect = new FlxRect();
	static var intersect:FlxRect = new FlxRect();
	static var flashRect:Rectangle = new Rectangle();

	/**
	 * A pixel-perfect collision check between two `FlxSprite`s. It will do a bounds check first, and, if that passes, it will run a
	 * pixel-perfect match on the intersecting area. Works with rotated and animated sprites. May be slow, so use it sparingly.
	 *
	 * @param Contact The first `FlxSprite` to test against.
	 * @param Target The second `FlxSprite` to test against. Sprite order is irrelevant.
	 * @param AlphaTolerance The tolerance value above which alpha pixels are included. Defaults to `1` (i.e., anything that is not fully invisible).
	 * @param Camera The game camera to use. If `null`, `FlxG.camera` is used.
	 * @return Whether the sprites collide.
	 */
	public static function pixelPerfectCheck(Contact:FlxSprite, Target:FlxSprite, AlphaTolerance:Int = 1, ?Camera:FlxCamera):Bool
	{
		// if either of the angles are non-zero, consider the angles of the sprites in the pixel check
		var advanced = (Contact.angle != 0) || (Target.angle != 0) || Contact.scale.x != 1 || Contact.scale.y != 1 || Target.scale.x != 1
			|| Target.scale.y != 1;

		Contact.getScreenBounds(boundsA, Camera);
		Target.getScreenBounds(boundsB, Camera);

		boundsA.intersection(boundsB, intersect.set());

		if (intersect.isEmpty || intersect.width < 1 || intersect.height < 1)
		{
			return false;
		}

		//	Thanks to Chris Underwood for helping with the translate logic :)
		matrixA.identity();
		matrixA.translate(-(intersect.x - boundsA.x), -(intersect.y - boundsA.y));

		matrixB.identity();
		matrixB.translate(-(intersect.x - boundsB.x), -(intersect.y - boundsB.y));

		Contact.drawFrame();
		Target.drawFrame();

		var testA:BitmapData = Contact.framePixels;
		var testB:BitmapData = Target.framePixels;

		var overlapWidth:Int = Std.int(intersect.width);
		var overlapHeight:Int = Std.int(intersect.height);

		// More complicated case, if either of the sprites is rotated
		if (advanced)
		{
			testMatrix.identity();

			// translate the matrix to the center of the sprite
			testMatrix.translate(-Contact.origin.x, -Contact.origin.y);

			// rotate the matrix according to angle
			testMatrix.rotate(Contact.angle * FlxAngle.TO_RAD);
			testMatrix.scale(Contact.scale.x, Contact.scale.y);

			// translate it back!
			testMatrix.translate(boundsA.width / 2, boundsA.height / 2);

			// prepare an empty canvas
			var testA2:BitmapData = FlxBitmapDataPool.get(Math.floor(boundsA.width), Math.floor(boundsA.height), true, FlxColor.TRANSPARENT, false);

			// plot the sprite using the matrix
			testA2.draw(testA, testMatrix, null, null, null, false);
			testA = testA2;

			// (same as above)
			testMatrix.identity();
			testMatrix.translate(-Target.origin.x, -Target.origin.y);
			testMatrix.rotate(Target.angle * FlxAngle.TO_RAD);
			testMatrix.scale(Target.scale.x, Target.scale.y);
			testMatrix.translate(boundsB.width / 2, boundsB.height / 2);

			var testB2:BitmapData = FlxBitmapDataPool.get(Math.floor(boundsB.width), Math.floor(boundsB.height), true, FlxColor.TRANSPARENT, false);
			testB2.draw(testB, testMatrix, null, null, null, false);
			testB = testB2;
		}

		boundsA.x = Std.int(-matrixA.tx);
		boundsA.y = Std.int(-matrixA.ty);
		boundsA.width = overlapWidth;
		boundsA.height = overlapHeight;

		boundsB.x = Std.int(-matrixB.tx);
		boundsB.y = Std.int(-matrixB.ty);
		boundsB.width = overlapWidth;
		boundsB.height = overlapHeight;

		boundsA.copyToFlash(flashRect);
		var pixelsA = testA.getPixels(flashRect);

		boundsB.copyToFlash(flashRect);
		var pixelsB = testB.getPixels(flashRect);

		var hit = false;

		// Analyze overlapping area of BitmapDatas to check for a collision (alpha values >= AlphaTolerance)
		var alphaA:Int = 0;
		var alphaB:Int = 0;
		var overlapPixels:Int = overlapWidth * overlapHeight;
		var alphaIdx:Int = 0;

		// check even pixels
		for (i in 0...Math.ceil(overlapPixels / 2))
		{
			alphaIdx = i << 3;
			pixelsA.position = pixelsB.position = alphaIdx;
			alphaA = pixelsA.readUnsignedByte();
			alphaB = pixelsB.readUnsignedByte();

			if (alphaA >= AlphaTolerance && alphaB >= AlphaTolerance)
			{
				hit = true;
				break;
			}
		}

		if (!hit)
		{
			// check odd pixels
			for (i in 0...overlapPixels >> 1)
			{
				alphaIdx = (i << 3) + 4;
				pixelsA.position = pixelsB.position = alphaIdx;
				alphaA = pixelsA.readUnsignedByte();
				alphaB = pixelsB.readUnsignedByte();

				if (alphaA >= AlphaTolerance && alphaB >= AlphaTolerance)
				{
					hit = true;
					break;
				}
			}
		}

		if (advanced)
		{
			FlxBitmapDataPool.put(testA);
			FlxBitmapDataPool.put(testB);
		}

		return hit;
	}

	/**
	 * A pixel-perfect collision check between a given x-/y-coordinate and an `FlxSprite`.
	 *
	 * @param PointX The x-coordinate of the point given in local space (relative to the `FlxSprite`, not game world coordinates).
	 * @param PointY The y-coordinate of the point given in local space (relative to the `FlxSprite`, not game world coordinates).
	 * @param Target The `FlxSprite` to check the point against.
	 * @param AlphaTolerance The alpha tolerance level above which pixels are counted as colliding. Defaults to `1` (i.e., anything that is not fully invisible).
	 * @return Whether the point collides with the `FlxSprite`.
	 */
	public static function pixelPerfectPointCheck(PointX:Int, PointY:Int, Target:FlxSprite, AlphaTolerance:Int = 1):Bool
	{
		// Intersect check
		if (!FlxMath.pointInCoordinates(PointX, PointY, Math.floor(Target.x), Math.floor(Target.y), Std.int(Target.width), Std.int(Target.height)))
		{
			return false;
		}

		if (FlxG.renderTile)
		{
			Target.drawFrame();
		}

		// How deep is pointX/Y within the rect?
		var test:BitmapData = Target.framePixels;

		var pixelAlpha = FlxColor.fromInt(test.getPixel32(Math.floor(PointX - Target.x), Math.floor(PointY - Target.y))).alpha;

		if (FlxG.renderTile)
		{
			pixelAlpha = Std.int(pixelAlpha * Target.alpha);
		}

		// How deep is pointX/Y within the rect?
		return pixelAlpha >= AlphaTolerance;
	}

	/**
	 * Creates a "wall" around the given camera which can be used for `FlxSprite` collision.
	 *
	 * @param Camera The `FlxCamera` to use for the wall bounds (can be `FlxG.camera` for the current one).
	 * @param PlaceOutside Whether to place the camera wall outside or inside.
	 * @param Thickness The thickness of the wall in pixels.
	 * @param AdjustWorldBounds Whether to adjust `FlxG.worldBounds` based on the wall.
	 * @return An `FlxGroup` containing the 4 `FlxTileblocks` that were created.
	 */
	public static function createCameraWall(Camera:FlxCamera, PlaceOutside:Bool = true, Thickness:Int, AdjustWorldBounds:Bool = false):FlxGroup
	{
		var left:FlxTileblock = null;
		var right:FlxTileblock = null;
		var top:FlxTileblock = null;
		var bottom:FlxTileblock = null;

		if (PlaceOutside)
		{
			left = new FlxTileblock(Math.floor(Camera.x - Thickness), Math.floor(Camera.y + Thickness), Thickness, Camera.height - (Thickness * 2));
			right = new FlxTileblock(Math.floor(Camera.x + Camera.width), Math.floor(Camera.y + Thickness), Thickness, Camera.height - (Thickness * 2));
			top = new FlxTileblock(Math.floor(Camera.x - Thickness), Math.floor(Camera.y - Thickness), Camera.width + Thickness * 2, Thickness);
			bottom = new FlxTileblock(Math.floor(Camera.x - Thickness), Camera.height, Camera.width + Thickness * 2, Thickness);

			if (AdjustWorldBounds)
			{
				FlxG.worldBounds.set(Camera.x - Thickness, Camera.y - Thickness, Camera.width + Thickness * 2, Camera.height + Thickness * 2);
			}
		}
		else
		{
			left = new FlxTileblock(Math.floor(Camera.x), Math.floor(Camera.y + Thickness), Thickness, Camera.height - (Thickness * 2));
			right = new FlxTileblock(Math.floor(Camera.x + Camera.width - Thickness), Math.floor(Camera.y + Thickness), Thickness,
				Camera.height - (Thickness * 2));
			top = new FlxTileblock(Math.floor(Camera.x), Math.floor(Camera.y), Camera.width, Thickness);
			bottom = new FlxTileblock(Math.floor(Camera.x), Camera.height - Thickness, Camera.width, Thickness);

			if (AdjustWorldBounds)
			{
				FlxG.worldBounds.set(Camera.x, Camera.y, Camera.width, Camera.height);
			}
		}

		var result = new FlxGroup();

		result.add(left);
		result.add(right);
		result.add(top);
		result.add(bottom);

		return result;
	}

	/**
	 * Calculates the point at which the given line, from start to end, first enters the rect.
	 * If the line starts inside the rect, a copy of `start` is returned.
	 * If the line never enters the rect, `null` is returned.
	 *
	 * Note: If a result vector is supplied and the line is outside the rect, `null` is returned
	 * and the supplied result is unchanged,
	 *
	 * @param rect The rect being entered.
	 * @param start The start of the line.
	 * @param end The end of the line.
	 * @param result Optional result vector, to avoid creating a new instance to be returned.
	 * Only returned if the line enters the rect.
	 * @return The point of entry of the line into the rect, if possible.
	 * @since 5.0.0
	 */
	public static function calcRectEntry(rect:FlxRect, start:FlxPoint, end:FlxPoint, ?result:FlxPoint):Null<FlxPoint>
	{
		// We must ensure that weak refs are placed back in the pool
		inline function putWeakRefs()
		{
			start.putWeak();
			end.putWeak();
			rect.putWeak();
		}

		// helper to create a new instance if needed, when needed.
		// this allows us to return a value at any point and still put weak refs.
		// otherwise this would be a fragile mess of if-elses
		function getResult(x:Float, y:Float)
		{
			if (result == null)
				result = FlxPoint.get(x, y);
			else
				result.set(x, y);

			putWeakRefs();
			return result;
		}

		function nullResult()
		{
			putWeakRefs();
			return null;
		}

		// does the ray start inside the bounds
		if (rect.containsPoint(start))
			return getResult(start.x, start.y);

		// are both points above, below, left or right of the bounds
		if ((start.y < rect.top && end.y < rect.top)
			|| (start.y > rect.bottom && end.y > rect.bottom)
			|| (start.x > rect.right && end.x > rect.right)
			|| (start.x < rect.left && end.x < rect.left))
		{
			return nullResult();
		}

		// check for purely vertical, i.e. has infinite slope
		if (start.x == end.x)
		{
			// determine if it exits top or bottom
			if (start.y < rect.top)
				return getResult(start.x, rect.top);

			return getResult(start.x, rect.bottom);
		}

		// Use y = mx + b formula to define out line, m = slope, b is y when x = 0
		var m = (start.y - end.y) / (start.x - end.x);
		// y - mx = b
		var b = start.y - m * start.x;
		// y = mx + b
		var leftY = m * rect.left + b;
		var rightY = m * rect.right + b;

		// if left and right intercepts are both above and below, there is no entry
		if ((leftY < rect.top && rightY < rect.top) || (leftY > rect.bottom && rightY > rect.bottom))
			return nullResult();

		// if ray moves right
		else if (start.x < end.x)
		{
			if (leftY < rect.top)
			{
				// ray exits on top
				// x = (y - b)/m
				return getResult((rect.top - b) / m, rect.top);
			}

			if (leftY > rect.bottom)
			{
				// ray exits on bottom
				// x = (y - b)/m
				return getResult((rect.bottom - b) / m, rect.bottom);
			}

			// ray exits to the left
			return getResult(rect.left, leftY);
		}

		// if ray moves left
		if (rightY < rect.top)
		{
			// ray exits on top
			// x = (y - b)/m
			return getResult((rect.top - b) / m, rect.top);
		}

		if (rightY > rect.bottom)
		{
			// ray exits on bottom
			// x = (y - b)/m
			return getResult((rect.bottom - b) / m, rect.bottom);
		}

		// ray exits to the right
		return getResult(rect.right, rightY);
	}

	/**
	 * Calculates the point at which the given line, from start to end, was last inside the rect.
	 * If the line ends inside the rect, a copy of `end` is returned.
	 * If the line is never inside the rect, `null` is returned.
	 *
	 * Note: If a result vector is supplied and the line is outside the rect, `null` is returned
	 * and the supplied result is unchanged.
	 *
	 * @param rect The rect being exited.
	 * @param start The start of the line.
	 * @param end The end of the line.
	 * @param result Optional result vector, to avoid creating a new instance to be returned.
	 * Only returned if the line enters the rect.
	 * @return The point of exit of the line from the rect, if possible.
	 * @since 5.0.0
	 */
	public static inline function calcRectExit(rect, start, end, result)
	{
		return calcRectEntry(rect, end, start, result);
	}
}

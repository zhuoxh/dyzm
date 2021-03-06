package dyzm.view.layer.fight.childLayer.mainLayer
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import asset.KnifeFire;
	
	import dyzm.data.role.RoleVo;
	import dyzm.manager.EventManager;

	public class BaseFire extends Sprite
	{
		public var mc:MovieClip;
		public var yy:Number;
		public var fireTypeToClass:Object = {
			1:asset.KnifeFire
		}
		public function BaseFire(fireType:int, _y:Number, fireRotation:int)
		{
			yy = _y;
			var c:Class = fireTypeToClass[fireType];
			mc = new c;
			mc.rotation = fireRotation;
			this.addChild(mc);
			this.addEventListener(Event.ADDED_TO_STAGE, toStage);
			
		}
		
		public function toStage(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, toStage);
			mc.addEventListener(Event.EXIT_FRAME, loop);
		}
		
		public function loop(e:Event):void
		{
			if (mc.currentFrame == mc.totalFrames){
				this.parent.removeChild(this);
				mc.removeEventListener(Event.EXIT_FRAME, loop);
				EventManager.dispatchEvent(RoleVo.REMOVE_FIRE_EVENT, this);
			}
		}
	}
}
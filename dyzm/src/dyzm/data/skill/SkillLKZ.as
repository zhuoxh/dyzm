package dyzm.data.skill
{
	import dyzm.data.RoleState;
	import dyzm.data.SkillData;
	import dyzm.data.role.RoleVo;
	
	public class SkillLKZ extends BaseSkillVo
	{
		/**
		 * 技能唯一标识
		 */
		public static const id:String = "裂空斩";
		/**
		 * 名称
		 */
		public static const name:String = "裂空斩";
		
		/**
		 * 所属系
		 */
		public static const xi:int = SkillData.XI_JIAN;
		
		/**
		 * 启动状态
		 */
		public static const startState:int = SkillData.SKY;
		
		/**
		 * 帧名称
		 */
		public static const frameName:String = "裂空斩";
		
		/**
		 * 可以打断的后摇
		 */
		public const CAN_CANCEL_AFTER:Array = ["剑系空中普攻", "升龙斩"];
		
		/**
		 * 该技能的后续技能可出招的时间范围
		 */
		public const SKILL_COMBO_TIME:int = 0;
		
		public const speedZ:Number = 30;
		
		public function SkillLKZ(role:RoleVo)
		{
			super(role);
			
			attSpot.isFly = false;
			attSpot.x = 300;
			attSpot.xFrame = 2;
			attSpot.z = 40;
			attSpot.upY = 40;
			attSpot.downY = 40;
			attSpot.stiffDecline = 0.2;
			attSpot.zDecline = 0.2;
			attSpot.attDecline = 0.3;
			attSpot.armorDecline = 0.3;
			attSpot.stiffFrame = 45;
			attSpot.curAttSpot = 1;
			attSpot.range = 8;
			attSpot.minBounceZ = -25;
			attSpot.canTurn = false;
			// 该技能可以攻击到的攻击块
			// 鹰踢可以攻击到已经倒地的玩家
			attSpot.byList = [AttInfo.BY_ATT_NORMAL, AttInfo.BY_ATT_FELL];
			// 攻击火花类型
			attSpot.attFireType = AttInfo.FIRE_TYPE_KNIFE;
			
			// 防御火花类型
			attSpot.defFireType = AttInfo.FIRE_TYPE_KNIFE;
			
			// 火花角度
			attSpot.attFireRotation = 0;
			
			attSpot.foeActionToHead = AttInfo.YANG_TIAN;
			
			attSpot.foeAction = AttInfo.DI_TOU;
		}	
		
		/**
		 * 技能检测, 在通过初步检测后调用,进入进一步判断
		 * 初步检测包括 是否符合技能的释放位置(地面,空中,跑步),并且不在被攻击状态
		 * @return ture=可以释放
		 */
		override public function startTest():Boolean
		{
			if (roleVo.attState == RoleState.ATT_AFTER_CANCEL || roleVo.attState == RoleState.ATT_NORMAL){
				return true;
			}
			if (roleVo.attState == RoleState.ATT_AFTER){
				for each (var id:String in CAN_CANCEL_AFTER) 
				{
					if (roleVo.curSkillClass.id == id){
						return true;
					}
				}
			}
			return false;
		}
		
		/**
		 * 技能开始
		 */
		override public function start():void
		{
			attSpot.attr.minAtt = roleVo.curAttr.minAtt;
			attSpot.attr.maxAtt = roleVo.curAttr.maxAtt;
			attSpot.attr.attArmor = roleVo.curAttr.attArmor;
			attSpot.attr.iceAtt = roleVo.curAttr.iceAtt;
			attSpot.attr.fireAtt = roleVo.curAttr.fireAtt;
			attSpot.attr.thundAtt = roleVo.curAttr.thundAtt;
			attSpot.attr.toxinAtt = roleVo.curAttr.toxinAtt;
			
			roleVo.frameName = frameName;
			roleVo.curFrame = 1;
			roleVo.attState = RoleState.ATT_BEFORE;
			super.start();
		}
		
		/** 
		 * 技能进行中,每帧调用
		 */
		override public function run():void
		{
			// 更新当前攻击状态
			roleVo.attState = SkillData.FRAME_TO_STATE[roleVo.roleMc.role.currentLabel];
			// 攻击中
			if (roleVo.attState == RoleState.ATT_ING && roleVo.curState != RoleState.STATE_NORMAL){ // 垂直向下冲击
				roleVo.z += speedZ;
				if (roleVo.z >= 0){ // 落地,进入该技能的耍帅动作
					roleVo.curFrame ++;
					roleVo.curState = RoleState.STATE_NORMAL;
					roleVo.setSkillComboTime(SKILL_COMBO_TIME);
					roleVo.inFlood();
					roleVo.reAction();
				}else if (roleVo.roleMc.role.currentLabel != "att2"){
					roleVo.curFrame ++;
				}
			}else{
				if (roleVo.roleMc.role.totalFrames == roleVo.curFrame){ // 动作完成
					roleVo.attState = RoleState.ATT_NORMAL;
					roleVo.curState = RoleState.STATE_NORMAL;
					end();
				}else{
					roleVo.curFrame ++;
				}
			}
			
			super.run();
		}
	}
}
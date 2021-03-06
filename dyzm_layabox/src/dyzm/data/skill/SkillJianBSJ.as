package dyzm.data.skill
{
	import dyzm.data.RoleState;
	import dyzm.data.buff.BrokenBuff;
	import dyzm.data.buff.ExplodeBuff;
	import dyzm.data.role.RoleVo;
	import dyzm.data.table.skill.SkillTable;
	import dyzm.data.table.skill.SkillTableVo;
	
	import laya.utils.Tween;

	public class SkillJianBSJ extends BaseSkillVo
	{
		/**
		 * 技能唯一标识
		 */
		public static const id:String = "剑系终结技";
		
		/**
		 * 技能信息
		 */
		public static var tableVo:SkillTableVo;
		
		/**
		 * 最低多少连击数可以出必杀
		 */
		public const MIN_COMBO:int = 15;
		
		/**
		 * 该技能出招时的位移效果
		 */
		public const speedX:int = 15;
		public const stopX:int = 5;
		public const addX:int = 20;
		public var curSpeedX:int = 0;
		
		public var actionList:Array;
		public var target:RoleVo;
		public var actionIndex:int;
		public var curAttSpot:int;
		public var phase:int;
		
		public var myBuff:Array;
		
		public static function getTableVo():SkillTableVo
		{
			if (tableVo == null){
				tableVo = new SkillTableVo();
				tableVo.id = id;
				tableVo.cls = SkillJianBSJ;
				tableVo.name = "终结技"; 
				tableVo.info = "剑系终结技,需要15连击以上才可发动";
				tableVo.xi = SkillTable.XI_JIAN;
				tableVo.startState = SkillTable.FLOOR;
				tableVo.frameName = "剑系终结技";
				tableVo.needGold = 50;
				tableVo.needDay = 1;
				tableVo.up1Name = "碎甲";
				tableVo.up1Info = "如果目标存活,只会恢复一半的护甲值";
				tableVo.up1Gold = 400;
				tableVo.up1Day = 5;
				tableVo.up2Name = "蓄力";
				tableVo.up2Info = "每多一连伤害加0.3";
				tableVo.up2Gold = 400;
				tableVo.up2Day = 5;
				tableVo.canCancelAfter = [SkillJian1.id, SkillJian2.id, SkillJian3.id, SkillYingTi.id, SkillLKZ.id, SkillST.id];
				tableVo.skillComboTime = 0;
			}
			return tableVo;
		}
		
		
		public function SkillJianBSJ()
		{
			super();
			// 该技能可以攻击到的攻击块
			// 鹰踢可以攻击到已经倒地的玩家
			attSpot.byList = [AttInfo.BY_ATT_NORMAL, AttInfo.BY_ATT_FELL];
			// 攻击火花类型
			attSpot.attFireType = AttInfo.FIRE_TYPE_KNIFE;
			
			// 防御火花类型
			attSpot.defFireType = AttInfo.FIRE_TYPE_KNIFE;
			
			attSpot.foeAction = AttInfo.YANG_TIAN;
		}
		
		/**
		 * 技能检测, 在通过初步检测后调用,进入进一步判断
		 * 初步检测包括 是否符合技能的释放位置(地面,空中,跑步),并且不在被攻击状态
		 * @return ture=可以释放
		 */
		override public function startTest():Boolean
		{
			
			if (roleVo.maxCombo < MIN_COMBO){
				return false;
			}
			var a:Array = roleVo.comboInfo[roleVo.maxComboRole.keyId];
			if (a[a.length-1] == tableVo.frameName){
				return false;
			}
			
			if (roleVo.attState == RoleState.ATT_AFTER_CANCEL || roleVo.attState == RoleState.ATT_NORMAL){
				return true;
			}
			if (roleVo.attState == RoleState.ATT_AFTER){
				for each (var id:String in tableVo.canCancelAfter)
				{
					if (roleVo.curSkillClass.id == id){
						return true;
					}
				}
				return false;
			}
			return false;
		}
		
		
		/**
		 * 技能开始
		 */
		override public function start():void
		{
			attSpot.isFly = false;
			attSpot.x = 0;
			attSpot.xFrame = 0;
			attSpot.z = 0;
			attSpot.upY = 40;
			attSpot.downY = 40;
			attSpot.stiffDecline = 0;
			attSpot.zDecline = 0;
			attSpot.attDecline = 0;
			attSpot.armorDecline = 0;
			attSpot.stiffFrame = 999;
			attSpot.curAttSpot = 1;
			attSpot.range = 2;
			attSpot.canTurn = false;
			attSpot.isStiff = true;
			
			attSpot.attr.minAtt = 0;
			attSpot.attr.maxAtt = 0;
			attSpot.attr.attArmor = 0;
			attSpot.attr.iceAtt = 0;
			attSpot.attr.fireAtt = 0;
			attSpot.attr.thundAtt = 0;
			attSpot.attr.toxinAtt = 0;
			attSpot.attr.critDmg = 0;
			attSpot.toBuff = null;
			target = roleVo.maxComboRole;
			actionList = roleVo.comboInfo[target.keyId].concat();
			actionIndex = 0;
			curAttSpot = 1;
			
			roleVo.frameName = getNextAction();
			roleVo.curFrame = 1;
			roleVo.attState = RoleState.ATT_ING;
			roleVo.curInvincibleFrame = 999999;
			phase = 0;
			
			super.start();
		}
		
		/**
		 * 技能进行中,每帧调用
		 */
		override public function run():void
		{
			var r:RoleVo
			if (phase < 60){ // 放光吸人阶段
				if (phase == 0){
					var tx:int = roleVo.x + roleVo.curTurn * 120;
					for each (r in roleVo.hitsInfo.idToObj) 
					{
						r.attState = RoleState.ATT_NORMAL;
						r.byAttInfo.stiffFrame = 999;
						r.byAttInfo.curStiffFrame = 0;
						r.curFrame = 1;
						r.frameName = Math.random() < 0.5 ? RoleVo.TAG_DI_TOU : RoleVo.TAG_YANG_TIAN;
						r.byAttInfo.x = 0;
						r.byAttInfo.z = 0;
						r.curState = RoleState.STATE_STIFF;
						Tween.to(r, {x:tx + Math.random() * 20, y:roleVo.y, z:0}, 1000);
					}
				}
				phase ++;
			}else{
				if (roleVo.frameName == tableVo.frameName){ // 必杀阶段
					if (roleVo.roleMc.totalFrames == roleVo.curFrame){ // 结束阶段
						roleVo.curInvincibleFrame = 0;
						end();
					}else{
						roleVo.curFrame ++;
						handleAtt(curAttSpot);
					}
				}else{ // 乱打阶段
					for (var i:int = 0; i < 4; i++)
					{
						roleVo.curFrame ++;
						roleVo.roleMc.childGotoAndStop(roleVo.curFrame);
						if (roleVo.roleMc.label == SkillTable.FRAME_AFTER){
							roleVo.frameName = getNextAction();
							if (roleVo.frameName == null){
								roleVo.frameName = tableVo.frameName;
								attSpot.isFly = true;
								attSpot.x = 300;
								attSpot.xFrame = 30;
								attSpot.z = -20;
								attSpot.upY = 40;
								attSpot.downY = 40;
								attSpot.stiffDecline = 0;
								attSpot.zDecline = 0;
								attSpot.attDecline = 0;
								attSpot.armorDecline = 0;
								attSpot.stiffFrame = 45;
								attSpot.curAttSpot = 1;
								attSpot.range = 16;
								attSpot.canTurn = false;
								attSpot.isStiff = true;
								
								attSpot.attr.minAtt = roleVo.curAttr.minAtt * 2;
								attSpot.attr.maxAtt = roleVo.curAttr.maxAtt * 2;
								if (type == 2){
									attSpot.attr.minAtt += roleVo.maxCombo * 0.3;
									attSpot.attr.maxAtt += roleVo.maxCombo * 0.3;
								}
								attSpot.toBuff = myBuff;
								
								attSpot.attr.attArmor = roleVo.curAttr.attArmor;
								attSpot.attr.iceAtt = roleVo.curAttr.iceAtt;
								attSpot.attr.fireAtt = roleVo.curAttr.fireAtt;
								attSpot.attr.thundAtt = roleVo.curAttr.thundAtt;
								attSpot.attr.toxinAtt = roleVo.curAttr.toxinAtt;
								attSpot.attr.critDmg = roleVo.curAttr.critDmg;
								attSpot.attFireRotation = -75;
							}else{
								// 火花角度
								attSpot.attFireRotation = 360 * Math.random();
							}
							needRange = true;
							curAttSpot ++;
							roleVo.curFrame = 1;
							
						}
						handleAtt(curAttSpot);
					}
				}
			}
		}
		
		public function getNextAction():String
		{
			var a:String;
			while(true){
				a = actionList[actionIndex ++];
				if (a != SkillBlock.tableVo.frameName && a != SkillJump.tableVo.frameName){
					return a;
				}
			}
			return null;
		}
		
		override public function set type(value:int):void
		{
			if (_type == value) return;
			_type = value;
			if (value == 1){
				if (myBuff){
					if (myBuff.length == 1){
						myBuff.push(BrokenBuff.TYPE);
					}
				}else{
					myBuff = [ExplodeBuff.TYPE, BrokenBuff.TYPE];
				}
			}else{
				if (myBuff == null){
					myBuff = [ExplodeBuff.TYPE];
				}
			}
		}
	}
}
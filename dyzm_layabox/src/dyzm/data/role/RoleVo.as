package dyzm.data.role
{
	import dyzm.data.FightData;
	import dyzm.data.RoleState;
	import dyzm.data.WorldData;
	import dyzm.data.attr.AttrVo;
	import dyzm.data.attr.BaseAttrVo;
	import dyzm.data.attr.GeniusVo;
	import dyzm.data.buff.BaseBuff;
	import dyzm.data.buff.BuffPool;
	import dyzm.data.skill.BaseSkillVo;
	import dyzm.data.skill.ByAttInfo;
	import dyzm.data.skill.SkillBlock;
	import dyzm.data.skill.SkillJump;
	import dyzm.manager.Cfg;
	import dyzm.manager.Evt;
	import dyzm.util.Dict;
	import dyzm.util.IDict;
	import dyzm.util.Maths;
	import dyzm.view.layer.fight.childLayer.mainLayer.BaseRole;
	import dyzm.view.layer.fight.childLayer.mainLayer.RoleView;
	
	import laya.maths.Point;
	
	public class RoleVo implements IDict
	{
		/**
		 * 动作帧名称
		 */
		public static const TAG_STOOD:String = "站立";
		public static const TAG_MOVE:String = "走";
		public static const TAG_RUN:String = "跑";
		public static const TAG_JUMP:String = "跳";
		public static const TAG_YANG_TIAN:String = "仰天";
		public static const TAG_DI_TOU:String = "低头";
		public static const TAG_FU_KONG:String = "浮空";
		public static const TAG_TAN_QI:String = "弹起";
		public static const TAG_DAO_DI:String = "倒地";
		public static const TAG_ZHAN_QI:String = "站起";
		public static const TAG_DOWNING:String = "倒下";
		public static const TAG_DEATH:String = "死亡";
		public static const TAG_BLOCK:String = "格挡";
		
		
		/**
		 * 添加被攻击火花事件
		 */
		public static const ADD_FIRE_EVENT:String = "ADD_FIRE_EVENT";
		
		/**
		 * 震动事件
		 */
		public static const RANGE_EVENT:String = "RANGE_EVENT";
		
		private var _keyId:int;
		
		/**
		 * 势力
		 */		
		public var team:int = 0;
		
		/**
		 * 视图显示位置
		 */
		public var x:Number = 0;
		public var y:Number = 0;
		
		/**
		 * 人物高度,用于在头上显示血条等
		 */
		public var h:Number = 100;
		
		/**
		 * 当前跳起的高度,高度命名为Z
		 */
		public var z:Number = 0;
		public var curFlyPower:Number = 0;
		
		/**
		 * 当前速度
		 */
		public var curMoveSpeedX:Number = 0;
		public var curMoveSpeedY:Number = 0;
		
		/**
		 * 是否跑步中
		 */
		public var isRuning:Boolean = false;
		
		/**
		 * 当前受控状态
		 */
		public var curState:int = RoleState.STATE_NORMAL;
		
		/**
		 * 当前攻击状态						<br>
		 * RoleState.ATT_NORMAL				<br>
		 * RoleState.ATT_BEFORE				<br>
		 * RoleState.ATT_ING				<br>
		 * RoleState.ATT_AFTER				<br>
		 * RoleState.ATT_AFTER_CANCEL		<br>
		 */
		public var attState:int = RoleState.ATT_NORMAL;
		
		/**
		 * 当前方向
		 */
		public var curDir:int = 5;
		
		/**
		 * 当前正在释放的技能
		 */
		public var curSkill:BaseSkillVo = null;
		
		/**
		 * 当前正在释放的技能类,用于连续技判断
		 */
		public var curSkillClass:Class = null;
		
		/**
		 * 当前动作帧名称
		 */
		public var frameName:String = TAG_STOOD;
		
		
		/**
		 * 当前帧,注意,是在帧标签中的帧
		 */
		public var curFrame:int = 1;
		
		/**
		 * 模型json路径
		 */
		public var style:String;
		
		/**
		 * 角色皮肤
		 */
		public var skin:RoleSkinVo;
		/**
		 * 当前人物模型
		 */
		public var roleMc:RoleView;
		
		/**
		 * 当前人物显示器
		 */
		public var roleSpr:BaseRole;
		
		/**
		 * 当前朝向,右=1,左=-1
		 */
		public var curTurn:int = 1;
		
		/**
		 * 人物的X轴缩放
		 */
		public var scaleX:Number = 1;
		
		/**
		 * 人物的Y轴缩放
		 */
		public var scaleY:Number = 1;
		
		/**
		 * 技能的第几招
		 */
		public var skillCombo:int = 0;
		
		/**
		 * 后续技能计时
		 */
		public var skillComboTime:int = 0;
		/**
		 * 后续技能总时间
		 */
		public var skillComboAllTime:int = 0;
		/**
		 * 攻击形态(1=地面,2=地面跑步,3=空中);
		 */
		public var attForm:int = 1;
		
		/**
		 * 正在执行的技能ID
		 */
		public var skillId:int = 0;
		
		
		public var byAttInfo:ByAttInfo;
		
		/**
		 * 无敌帧数
		 */
		public var curInvincibleFrame:int = 0;
		
		/**
		 * 连击数记录
		 */
		public var hitsInfo:Dict;
		
		/**
		 * 本次被攻击,攻击我的玩家列表
		 */
		public var byAttRoleList:Dict;
		
		/**
		 * 最大连击数
		 */
		public var maxCombo:int = 0;
		
		/**
		 * 造成最大连击的人
		 */
		public var maxComboRole:RoleVo;
		
		/**
		 * 人物属性
		 */
		public var attr:AttrVo;
		
		/**
		 * 人物天赋
		 */
		public var genius:GeniusVo;
		
		/**
		 * 当前人物属性
		 */
		public var curAttr:BaseAttrVo;
		
		/**
		 * 需要删除该人物时,为true
		 */
		public var needDel:Boolean = false;
		
		/**
		 * 跳到空中时的攻击记录,落地后清空
		 */
		public var jumpInfo:Object = {};
		
		public var comboInfo:Object;
		
		public var jumpSkill:SkillJump;
		
		public var buffList:Array = [];
		
		/**
		 * 尸体爆炸计时
		 */
		public var explodeFrame:int = -1;
		
		public function RoleVo()
		{
			_keyId = Cfg.getKeyId();
			comboInfo = {};
			byAttInfo = new ByAttInfo();
			attr = new AttrVo();
			curAttr = new AttrVo();
			byAttRoleList = new Dict();
			hitsInfo = new Dict();
		}
		
		public function get keyId():int
		{
			return _keyId;
		}
		
		public function initAttr(a:AttrVo):void
		{
			attr = a;
			curAttr.toZero();
			curAttr.add(attr);
			curAttr.hp = attr.maxHp;
			curAttr.armor = curAttr.maxArmor;
		}
		
		/**
		 * 动作复位, 比如跳跃完毕,技能完毕等时候调用
		 * 通过状态对人物动作进行调整
		 * 该函数不会改变现有状态
		 * 子类覆盖
		 */
		public function reAction():void
		{
			if(attState == RoleState.ATT_NORMAL && curState == RoleState.STATE_AIR){
				frameName = TAG_JUMP;
				if (curFlyPower < 0){
					curFrame = 5;
				}else{
					curFrame = 21;
				}
			}
			isRuning = false;
		}
		
		/**
		 * 落地, 凡是落到地上,都需要调用该函数
		 */
		public function inFlood():void
		{
			z = 0;
			jumpInfo = {};
			isRuning = false;
		}
		
		/**
		 * 设置技能的后续技能可出招的时间范围,单位:帧
		 */
		public function setSkillComboTime(time:int):void
		{
			if (time == 0){
				skillId = 0;
				skillCombo = 0;
				skillComboTime = 0;
				skillComboAllTime = 0;
			}else{
				skillCombo ++;
				skillComboTime = 0;
				skillComboAllTime = time;
			}
		}
		
		/**
		 * 是否处于无法被攻击状态
		 * @return 
		 */
		public function isInvincible():Boolean
		{
			return explodeFrame != -1 || curInvincibleFrame > 0;
		}
		
		/**
		 * 被攻击
		 * @param attRole 攻击者
		 * @param skill 攻击技能
		 * @param a		技能段
		 * @param rect	攻击交接范围
		 * @param b	被攻击的块ID,0为头部
		 * @return 是否攻击到
		 */
		public function byHit(attRole:RoleVo, skill:BaseSkillVo, a:int, firePoint:Point, b:int, buffList:Array):Boolean
		{
			if (!skill.attSpot.isStiff){
				if (curSkill as SkillBlock){
					if ((curSkill as SkillBlock).byHit(attRole, skill, a, firePoint, b)){
						return false;
					}
				}
			}
			
			// buff处理
			if (buffList){
				for (var i:int = 0; i < buffList.length; i++) 
				{
					addBuff(attRole, buffList[i]);
				}
			}
			
			// 重复攻击递减
			var skillRepeat:Number = getSkillRepeat(skill);
			// 伤害处理
			var att:Number = Maths.random(skill.attSpot.attr.minAtt, skill.attSpot.attr.maxAtt); // 计算发挥的攻击力大小
			// 暴击计算
			var isCrit:Boolean = skill.attSpot.isCrit; // 是否必定暴击
			if (!isCrit){ // 没有暴击的话,处理天赋暴击
				var hits:int = attRole.getHitNum(this); // 获得自己的被连击数
				if(attRole.genius.hasOwnProperty("blast" + hits) && attRole.genius["blast" + hits]){ // 是否开启了这个天赋
					isCrit = true;
				}
			}
			if (isCrit){ // 暴击处理
				att = att + skill.attSpot.attr.critDmg;
			}
			
			att = att - att * skillRepeat * skill.attSpot.armorDecline; // 计算重复攻击递减
			att = att - curAttr.def; // 计算防御减伤
			var iceAtt:Number = skill.attSpot.attr.iceAtt;
			// 冰攻击
			iceAtt =  iceAtt - iceAtt * skillRepeat * skill.attSpot.armorDecline - curAttr.iceDef;
			var fireAtt:Number = skill.attSpot.attr.fireAtt;
			// 火攻击
			fireAtt =  fireAtt - fireAtt * skillRepeat * skill.attSpot.armorDecline - curAttr.fireDef;
			// 电攻击
			var thundAtt:Number = skill.attSpot.attr.thundAtt;
			thundAtt =  thundAtt - thundAtt * skillRepeat * skill.attSpot.armorDecline - curAttr.thundDef;
			// 毒攻击
			var toxinAtt:Number = skill.attSpot.attr.toxinAtt;
			toxinAtt =  toxinAtt - toxinAtt * skillRepeat * skill.attSpot.armorDecline - curAttr.toxinDef;
			var curAtt:Number = 0;
			if (att > 0){
				curAtt += att;
			}
			if (iceAtt > 0){
				curAtt += iceAtt;
			}
			if (fireAtt > 0){
				curAtt += fireAtt;
			}
			if (thundAtt > 0){
				curAtt += thundAtt;
			}
			if (toxinAtt > 0){
				curAtt += toxinAtt;
			}
			
			curAtt = curAtt - curAttr.armor; // 计算护甲减伤
			if (Math.random() < curAtt - int(curAtt)){
				curAtt = int(curAtt) + 1;
			}else{
				curAtt = int(curAtt);
			}
			
			// 破甲计算
			var curAttArmor:int = skill.attSpot.attr.attArmor;
			curAttr.armor -= curAttArmor;
			if (curAttr.armor < 0 ){
				curAttArmor += curAttr.armor;
				curAttr.armor = 0;
			}
			if (curAtt > 0){
				curAttr.hp -= curAtt;
				if (curAttr.hp < 0){
					curAttr.hp = 0;
					curAttr.armor = 0;
				}
			}
			if (curAtt <= 0 && curAttArmor > 0){
				Evt.event(ADD_FIRE_EVENT, [firePoint, skill.attSpot.attFireType, y+1, skill.attSpot.attFireRotation * attRole.curTurn, "armor", skill.attSpot.attr.attArmor, isCrit]);
			}else if (curAttr.armor > 0){
				Evt.event(ADD_FIRE_EVENT, [firePoint, skill.attSpot.attFireType, y+1, skill.attSpot.attFireRotation * attRole.curTurn, "armor", skill.attSpot.attr.attArmor, isCrit]);
			}else{
				Evt.event(ADD_FIRE_EVENT, [firePoint, skill.attSpot.attFireType, y+1, skill.attSpot.attFireRotation * attRole.curTurn, "hp", curAtt, isCrit]);
			}
			
			if ((curAtt > 0 && curAttr.armor == 0) || skill.attSpot.isStiff || curAttr.hp <= 0){ // 扣血了,并且护甲被破
				// 清理原来动作
				if (attState != RoleState.ATT_NORMAL){
					attState = RoleState.ATT_NORMAL;
					curSkill = null;
				}
				
				// 被攻击记录
				if (byAttInfo.hitDict){
					if (byAttInfo.hitDict[skill.keyId]){
						if (byAttInfo.hitDict[skill.keyId][skill.attSpot.curAttSpot]){
							byAttInfo.hitDict[skill.keyId][skill.attSpot.curAttSpot] ++;
						}else{
							byAttInfo.hitDict[skill.keyId][skill.attSpot.curAttSpot] = 1;
						}
					}else{
						byAttInfo.hitDict[skill.keyId] = {};
						byAttInfo.hitDict[skill.keyId][skill.attSpot.curAttSpot] = 1;
					}
				}else{
					byAttInfo.hitDict = {};
					byAttInfo.hitDict[skill.keyId] = {};
					byAttInfo.hitDict[skill.keyId][skill.attSpot.curAttSpot] = 1;
				}
				
				// 记下本次谁打了我
				byAttRoleList.setData(attRole, true);
				
				
				// 表现处理
				if ((curState == RoleState.STATE_NORMAL || curState == RoleState.STATE_STIFF) && skill.attSpot.isFly == false){ // 地面状态
					var stiffDecline:int = skill.attSpot.stiffFrame - skill.attSpot.stiffFrame * skillRepeat * skill.attSpot.stiffDecline;
					if (stiffDecline > 0){
						var s:int = (byAttInfo.stiffFrame - byAttInfo.curStiffFrame);
						if (s > skill.attSpot.stiffFrame){
							byAttInfo.stiffFrame = s;
						}else{
							byAttInfo.stiffFrame = skill.attSpot.stiffFrame;
						}
						byAttInfo.curStiffFrame = 0;
						curSkill = null;
						curState = RoleState.STATE_STIFF;
						if (b == 0){
							frameName = skill.attSpot.foeActionToHead;
						}else{
							frameName = skill.attSpot.foeAction;
						}
						curFrame = 1;
						byAttInfo.x = (skill.attSpot.x / byAttInfo.stiffFrame) * attRole.curTurn; // 每帧位移量
					}
				}else{ // 浮空状态
					byAttInfo.stiffFrame = 0;
					byAttInfo.curStiffFrame = 0;
					curSkill = null;
					curState = RoleState.STATE_FLY;
					frameName = TAG_FU_KONG;
					curFrame = 1;
					byAttInfo.x = skill.attSpot.xFrame * attRole.curTurn;
					// 处理浮空递减
					byAttInfo.z = skill.attSpot.z - skill.attSpot.z * skillRepeat * skill.attSpot.zDecline;
					byAttInfo.minBounceZ = skill.attSpot.minBounceZ - skill.attSpot.minBounceZ * skillRepeat * skill.attSpot.zDecline;
				}
				curTurn = -attRole.curTurn;
				return true;
			}
			return false;
		}
		
		/**
		 * 获得对某一敌人的连击数
		 * @param roleVo
		 * @return 
		 */
		public function getHitNum(roleVo:RoleVo):int
		{
			return int(hitsInfo.getData(roleVo));
		}
		
		/**
		 * 获得技能重复攻击次数
		 * @param skill
		 * @return 
		 */
		public function getSkillRepeat(skill:BaseSkillVo):int
		{
			if (byAttInfo.hitDict && byAttInfo.hitDict[skill.keyId] && byAttInfo.hitDict[skill.keyId][skill.attSpot.curAttSpot]){
				return int(byAttInfo.hitDict[skill.keyId][skill.attSpot.curAttSpot]);
			}
			return 0;
		}

		/**
		 * 添加BUFF,相同buff不可叠加
		 * @param source
		 * @param buff
		 */
		public function addBuff(source:RoleVo, buffType:String):void
		{
			for (var i:int = 0; i < buffList.length; i++) 
			{
				if (buffList[i].type == buffType) return;
			}
			
			var buff:BaseBuff = BuffPool.getBuff(buffType);
			var b:Boolean = buff.add(this, source);
			if (b){
				buffList.push(buff);
			}else{
				BuffPool.inPool(buff);
			}
		}
		
		/**
		 * 移除buff
		 * @param buff
		 */
		public function removeBuff(buff:BaseBuff):void
		{
			var index:int = buffList.indexOf(buff);
			if (index != -1){
				buffList.removeAt(index);
			}
		}
		
		public function addHit(foeRole:RoleVo):void
		{
			if (comboInfo[foeRole.keyId]){
				comboInfo[foeRole.keyId].push(curSkillClass.tableVo.frameName);
			}else{
				comboInfo[foeRole.keyId] = [curSkillClass.tableVo.frameName];
			}
			if(hitsInfo.has(foeRole)){
				hitsInfo.setData(foeRole, hitsInfo.getData(foeRole) + 1);
			}else{
				hitsInfo.setData(foeRole, 1);
			}
			if (hitsInfo.getData(foeRole) > maxCombo){
				maxCombo = hitsInfo.getData(foeRole);
				maxComboRole = foeRole;
			}
		}
		
		public function removeHit(foeRole:RoleVo):void
		{
			delete comboInfo[foeRole.keyId];
			if (hitsInfo.getData(foeRole) >= maxCombo){
				hitsInfo.delData(foeRole);
				maxCombo = 0;
				for each (var r:RoleVo in hitsInfo.idToObj){
					if (hitsInfo.getData(r) > maxCombo){
						maxCombo = hitsInfo.getData(r);
						maxComboRole = r;
					}
				}
			}else{
				hitsInfo.delData(foeRole);
			}
		}
		
		/**
		 * 设置无敌帧数
		 */
		public function setInvincibleFrame(i:int):void
		{
			if (curInvincibleFrame < i){
				curInvincibleFrame = i;
			}
		}
		
		/**
		 * 死亡爆炸
		 */
		public function explode():void
		{
			roleSpr.explode();
			explodeFrame = 120;
		}
		
		/**
		 * 帧率更新
		 */
		public function frameUpdate():void
		{
			var r:RoleVo;
			if (explodeFrame != -1){
				explodeFrame --;
				if (explodeFrame == 60){
					byAttInfo.hitDict = null;
					for each (r in byAttRoleList.idToObj) 
					{
						r.removeHit(this);
					}
					byAttRoleList.toEmpty();
				}else if (explodeFrame == 0){
					needDel = true;
				}
				return;
			}
			// buff处理
			for (var i:int = 0; i < buffList.length; i++) 
			{
				buffList[i].frameUpdate();
			}
			// 无敌时间减少
			if (curInvincibleFrame > 0){
				curInvincibleFrame --;
			}
			// 后续技能计时
			if (skillComboAllTime != 0){
				skillComboTime ++;
				if (skillComboTime > skillComboAllTime){
					skillComboTime = 0;
					skillComboAllTime = 0;
				}
			}
			// 运行技能
			if (curSkill){ // 当前有技能正在释放,进入技能循环,普通状态取消,人物行动状态交给技能控制
				curSkill.run();
				return;
			}
			// 常规状态处理
			switch(curState)
			{
				case RoleState.STATE_NORMAL: // 正常状态
				{
					x += curMoveSpeedX;
					y += curMoveSpeedY;
					if (y > FightData.level.bottomY){
						y = FightData.level.bottomY;
					}else if (y < FightData.level.topY){
						y = FightData.level.topY;
					}
					if (roleMc.totalFrames == curFrame){
						curFrame = 1;
					}else{
						curFrame ++;
					}
					break;
				}
				case RoleState.STATE_AIR: // 空中状态
				{
					x += curMoveSpeedX;
					y += curMoveSpeedY;
					if (y > FightData.level.bottomY){
						y = FightData.level.bottomY;
					}else if (y < FightData.level.topY){
						y = FightData.level.topY;
					}
					z += curFlyPower;
					
					if (z >= 0){ // 落地
						if (jumpSkill && jumpSkill.type == 2){
							jumpSkill.end();
						}
						inFlood();
						curState = RoleState.STATE_NORMAL;
						reAction();
					}else{
						if (curFlyPower > 0 || roleMc.label != "top" && curFrame < roleMc.totalFrames){
							curFrame ++;
						}
						curFlyPower -= WorldData.G;
					}
					break;
				}
				case RoleState.STATE_STIFF: // 硬直状态
				{
					if (byAttInfo.curStiffFrame == byAttInfo.stiffFrame){ // 硬直结束
						byAttInfo.hitDict = null;
						for each (r in byAttRoleList.idToObj) 
						{
							r.removeHit(this);
						}
						byAttRoleList.toEmpty();
						if (curAttr.hp == 0){
							curState = RoleState.STATE_DOWNING;
							frameName = TAG_DOWNING;
							curFrame = 1;
						}else{
							curAttr.armor = curAttr.maxArmor;
							curState = RoleState.STATE_NORMAL;
							reAction();
						}
						
					}else{
						if(byAttInfo.stiffFrame - byAttInfo.curStiffFrame <= 8){
							curFrame = 17 - (byAttInfo.stiffFrame - byAttInfo.curStiffFrame);
						}else{
							x += byAttInfo.x;
							if (roleMc.label != "stop"){
								curFrame ++;
							}
						}
						byAttInfo.curStiffFrame ++;
					}
					break;
				}
					
				case RoleState.STATE_FLY: // 浮空状态
				{
					x += byAttInfo.x;
					z += byAttInfo.z;
					if (z >= 0){ // 落地反弹
						z = 0;
						curState = RoleState.STATE_BOUNCE;
						frameName = TAG_TAN_QI;
						curFrame = 1;
						byAttInfo.x = byAttInfo.x * 2 / 3; // x轴位移减少1/3
						byAttInfo.z = Math.min(byAttInfo.minBounceZ, -byAttInfo.z / 2); //弹起动力为落地动力的一半
					}else{
						if (byAttInfo.z <= 0){ // 上升阶段
							if (roleMc.label != "up"){
								curFrame ++;
							}
						}else{ // 下降阶段
							if (curFrame < roleMc.totalFrames){
								curFrame ++;
							}
						}
						byAttInfo.z -= WorldData.G;
					}
					break;
				}
				case RoleState.STATE_BOUNCE: // 弹起状态
				{
					x += byAttInfo.x;
					z += byAttInfo.z;
					if (z >= 0){ // 落地
						if (byAttInfo.z > 20){ // 如果落地时,冲击力过大,那就需要再弹一次
							byAttInfo.z = -byAttInfo.z / 2;
							curFrame = 1;
							z = 0;
						}else{
							inFlood();
							curState = RoleState.STATE_FLOOD;
							frameName = TAG_DAO_DI;
							curFrame = 1;
						}
					}else{
						if (byAttInfo.z <= 0){ // 上升阶段
							if (roleMc.label != "up"){
								curFrame ++;
							}
						}else{ // 下降阶段
							if (curFrame < roleMc.totalFrames){
								curFrame ++;
							}
						}
						byAttInfo.z -= WorldData.G;
					}
					break;
				}
				case RoleState.STATE_FLOOD: // 倒地状态
				{
					if (curFrame == roleMc.totalFrames){ // 倒地结束, 进入站起状态或死亡状态
						byAttInfo.hitDict = null;
						for each (r in byAttRoleList.idToObj) 
						{
							r.removeHit(this);
						}
						byAttRoleList.toEmpty();
						if (curAttr.hp == 0){
							curState = RoleState.STATE_DEATH;
							frameName = TAG_DEATH;
							curFrame = 1;
						}else{
							curState = RoleState.STATE_STAND_UP;
							frameName = TAG_ZHAN_QI;
							curFrame = 1;
						}
					}else{
						curFrame ++;
					}
					break;
				}
				case RoleState.STATE_STAND_UP: // 站起状态
				{
					if (curFrame == roleMc.totalFrames){ // 站起结束,设置2秒无敌,进入正常状态
						curState = RoleState.STATE_NORMAL;
						setInvincibleFrame(attr.invincibleFrame);
						curAttr.armor = curAttr.maxArmor;
						reAction();
					}else{
						curFrame ++;
					}
					break;
				}
				case RoleState.STATE_DOWNING: // 倒下状态
				{
					if (curFrame == roleMc.totalFrames){
						if (curAttr.hp == 0){
							needDel = true;
						}else{
							curState = RoleState.STATE_FLOOD;
							frameName = TAG_DAO_DI;
							curFrame = 1;
						}
					}else{
						curFrame ++;
					}
					break;
				}
				case RoleState.STATE_DEATH: // 死亡状态
				{
					if (curFrame == roleMc.totalFrames){
						needDel = true;
					}else{
						curFrame ++;
					}
					break;
				}
				default:
				{
					break;
				}
			}
		}
	}
}
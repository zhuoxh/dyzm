package dyzm.view.base.ui
{
	import dyzm.Res;
	
	import laya.ui.Button;
	
	public class BaseBtn extends Button
	{
		public function BaseBtn(skin:String = null, label:String = "")
		{
			var s:String = skin;
			if (s == null){
				s = Res.btn;
			}
			super(s, label);
			if (skin == null){
				this.labelSize = 32;
				this.sizeGrid = "4,4,4,4";
			}
		}
	}
}
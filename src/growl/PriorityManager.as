/**
* @author ogawahideko
*/
package growl {
	public class PriorityManager {
		public const PRIORITY_HIGHER:int = 4;
		public const PRIORITY_HIGH:int = 3;
		public const PRIORITY_MIDDLE:int = 2;
		public const PRIORITY_LOW:int = 1;
		public const PRIORITY_LOWER:int = 0;

		private const BACK_COLORS:Array = [0x000000, 0x000000, 0x000000, 0xEE7800, 0xC9171E];
		private const FORE_COLORS:Array = [0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0x000000, 0xFFFFFF];


		private var _autoHiddenPriority:int = PRIORITY_LOW;


		public function getBackgroundColor(priority:int):uint {
			return BACK_COLORS[priority];
		}

		public function getColor(priority:int):uint {
			return FORE_COLORS[priority];
		}

		public function isAutoHidden(priority:int):Boolean {
			return (_autoHiddenPriority >= priority);
		}

		public function getTimeToLive(priority:int):int {
			return 10;
		}

	}

}
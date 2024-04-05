import Foundation
import SnackBar

public class AppSnackBar: SnackBar {
    public override var style: SnackBarStyle {
            var style = SnackBarStyle()
            style.background = .red
            style.textColor = .green
            return style
        }
}

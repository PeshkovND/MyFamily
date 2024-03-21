import UIKit
import AppEntities
import AppDesignSystem
import AppBaseFlow
import AVKit

final class AddPostViewController: BaseViewController<AddPostViewModel,
                                AddPostViewEvent,
                                AddPostViewState,
                                AddPostViewController.ContentView> {
    
    private let colors = appDesignSystem.colors
    
    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper
    
    deinit {
        viewModel.onViewEvent(.deinit)
    }
    
    private var textView: UITextView { contentView.textView }
    private var sendButton: ActionButton { contentView.sendButton }
    private var addMediaContainer: UIView { contentView.addMediaContainer }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeKeyboard()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            addMediaContainer.snp.removeConstraints()
            addMediaContainer.snp.updateConstraints {
                $0.bottom.equalTo(view.snp.bottom).inset(keyboardSize.height - 1)
                $0.leading.equalToSuperview().inset(-1)
                $0.trailing.equalToSuperview().inset(-1)
                $0.height.equalTo(64)
            }
        }
    }
    
    @objc func  keyboardWillHide(_ notification: Notification) {
        addMediaContainer.snp.removeConstraints()
        addMediaContainer.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(-1)
            $0.leading.equalToSuperview().inset(-1)
            $0.trailing.equalToSuperview().inset(-1)
            $0.height.equalTo(64)
        }
    }
    
    override func onViewState(_ viewState: AddPostViewState) {
        switch viewState {
        default:
            break
        }
    }
    
    private func configureView() {
        self.contentView.backgroundColor = colors.backgroundPrimary
        viewModel.onViewEvent(.viewDidLoad)
        textView.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        addMediaContainer.addGestureRecognizer(gesture)
        
        sendButton.onTap = {
            if self.textView.textColor != UIColor.lightGray {
                print("send")
            }
        }
    }
    
    @objc
    private func closeKeyboard() {
        textView.resignFirstResponder()
    }
}

extension AddPostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = appDesignSystem.strings.postScreenCommentPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
}

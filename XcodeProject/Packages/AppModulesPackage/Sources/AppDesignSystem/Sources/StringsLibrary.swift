//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

public struct StringsLibrary {

    // MARK: - Init
    
    init() {}

    private func localized(_ name: String) -> String {
        NSLocalizedString(name, bundle: .module, comment: "")
    }

    private func formatted(_ localizedString: String, arg: String) -> String {
        String(format: localizedString, arg)
    }
}

// MARK: - App Strings

extension StringsLibrary {

    // MARK: - Common

    public var commonOk: String { localized("common_ok") }
    public var commonSignIn: String { localized("common_sign_in") }
    public var commonPhoneNumber: String { localized("common_phone_number") }
    public var commonContinue: String { localized("common_continue") }
    public var commonChange: String { localized("common_change") }
    public var commonNext: String { localized("common_next") }
    public var commonCancel: String { localized("common_cancel") }
    public var commonClose: String { localized("common_close") }
    public var commonSettings: String { localized("common_settings") }
    public var commonConfirmation: String { localized("common_confirmation") }
    public var commonDone: String { localized("common_done") }
    public var commonOpenSettings: String { localized("common_use_open_settings") }

    // MARK: - Common Errors

    public var commonError: String { localized("common_error") }
    public var commonUnexpectedError: String { localized("common_unexpected_error") }
    public var commonAuthErrorTitle: String { localized("common_auth_error_title") }
    public var commonAuthErrorMessage: String { localized("common_auth_error_message") }
    public var commonLoading: String { localized("common_loading") }

    public var commonErrorNetwork: String { localized("common_error_network") }

    // MARK: - Welcome

    public var welcomeTermsServicePrivacyPolicy: String { localized("welcome_terms_service_privacy_policy") }
    public var welcomeTermsService: String { localized("welcome_terms_service") }
    public var welcomePrivacyPolicy: String { localized("welcome_privacy_policy") }

    // MARK: - Sign In

    public func signInWeSentCodeTo(formattedPhoneNumber: String) -> String {
        formatted(
            localized("sign_in_we_sent_code_to"),
            arg: formattedPhoneNumber
        )
    }
    public var signInVerifyContentTitle: String { localized("sign_in_verify_content_title") }
    public var signInAuthErrorTitle: String { localized("sign_in_auth_error_title") }
    public var signInAuthErrorMessage: String { localized("sign_in_auth_error_message") }
    public var signInVerifyPlaceholder: String { localized("sign_in_verify_placeholder") }
    public var signInResentButtonActive: String { localized("sign_in_resent_button_active") }
    public func signInResentButtonDisable(formattedTimer: String) -> String {
        formatted(
            localized("sign_in_resent_button_disable"),
            arg: formattedTimer
        )
    }

    public var signInPhoneContentTitle: String { localized("sign_in_phone_content_title") }
    public var signInPhoneCaption: String { localized("sign_in_phone_caption") }

    public var signInErrorSmsCodeIsInvalid: String { localized("sign_in_error_sms_code_is_invalid")
    }
    public var signInErrorSmsCodeExpired: String {
        localized("sign_in_error_sms_code_expired")
    }
    public func signInErrorExceedLimitSmsCode(seconds: String) -> String {
        formatted(
            localized("sign_in_error_exceed_limit_sms_code"),
            arg: seconds
        )
    }
    
    public var signInWithVk: String { localized("sign_in_vk") }
    public var signInTitle: String { localized("sign_in_title") }
    public var signInSubtitle: String { localized("sign_in_subtitle") }
    
    public var tabBarMapTitle: String { localized("tabbar_map_title") }
    public var tabBarNewsTitle: String { localized("tabbar_news_title") }
    public var tabBarFamilyTitle: String { localized("tabbar_family_title") }
    public var tabBarProfileTitle: String { localized("tabbar_profile_title") }
    
    public var statusOnlineTitle: String { localized("status_online_title") }
    public var statusOfflineTitle: String { localized("status_offline_title") }
    public var statusAtHomeTitle: String { localized("status_athome_title") }
    
    public var profilePostsTitle: String { localized("profile_posts_title") }
    public var profileSignOut: String { localized("profile_sign_out") }
    public var profileGetPro: String { localized("profile_get_pro") }
    public var profileEditProfile: String { localized("profile_edit_profile") }
    
    public var getProHeader: String { localized("get_pro_header") }
    public var getProFirstAdvantage: String { localized("get_pro_first_advantage") }
    public var getProSecondAdvantage: String { localized("get_pro_second_advantage") }
    public var getProBuy: String { localized("get_pro_buy") }
    public var getProRestorePurchases: String { localized("get_pro_restore_purchases") }
    public var getProPurchaseFailedTitle: String { localized("get_pro_purchase_failed_title") }
    public var getProPurchaseFailedDescription: String { localized("get_pro_purchase_failed_description") }
    public var getProContentLoadingError: String { localized("get_pro_content_loading_error") }
    public var getProRetry: String { localized("get_pro_retry") }
    
    public var postScreenTitle: String { localized("post_screen_title") }
    public var postScreenCommentPlaceholder: String { localized("post_screen_comment_placeholder") }
    
    public var addPostScreenTitle: String { localized("add_post_screen_title") }
    
    public var addPostCamera: String { localized("add_post_camera") }
    public var addPostGallery: String { localized("add_post_gallery") }
    public var addPostScreenPlaceholder: String { localized("add_post_screen_placeholder") }
    public var addPostRecord: String { localized("add_post_record") }
    public var addPostChooseAudioFile: String { localized("add_post_choose_audio_file") }
    public var addPostErrorTitle: String { localized("add_post_error_title") }
    public var addPostErrorSubtitle: String { localized("add_post_error_subtitle") }
    
    public var editProfileScreenTitle: String { localized("edit_profile_screen_title") }
    public var editProfileNameTitle: String { localized("edit_profile_name_title") }
    public var editProfileSurnameTitle: String { localized("edit_profile_surname_title") }
    public var editProfileErrorTitle: String { localized("edit_profile_error_title") }
    public var editProfileErrorSubtitle: String { localized("edit_profile_error_subtitle") }
    
    public var postAudioLoadingError: String { localized("post_audio_loading_error") }
    public var postAddCommentErrorTitle: String { localized("post_add_comment_error_title") }
    public var postAddCommentErrorSubtitle: String { localized("post_add_comment_error_subtitle") }
    
    public var contentLoadingErrorTitle: String { localized("content_loading_error_title") }
    public var contentLoadingErrorSubitle: String { localized("content_loading_error_subtitle") }
}

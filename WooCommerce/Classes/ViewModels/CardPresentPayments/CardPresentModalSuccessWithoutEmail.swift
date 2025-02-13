import UIKit

/// Modal presented when the payment has been collected successfully
final class CardPresentModalSuccessWithoutEmail: CardPresentPaymentsModalViewModel {

    /// Amount charged
    private let amount: String

    /// Closure to execute when primary button is tapped
    private let printReceiptAction: () -> Void

    let textMode: PaymentsModalTextMode = .noBottomInfo
    let actionsMode: PaymentsModalActionsMode = .twoAction

    let topTitle: String = Localization.paymentSuccessful

    var topSubtitle: String? {
        amount
    }

    let image: UIImage = .celebrationImage

    let primaryButtonTitle: String? = Localization.printReceipt

    let secondaryButtonTitle: String? = Localization.noThanks

    let auxiliaryButtonTitle: String? = nil

    let bottomTitle: String? = nil

    let bottomSubtitle: String? = nil

    init(amount: String, printReceipt: @escaping () -> Void) {
        self.amount = amount
        self.printReceiptAction = printReceipt
    }

    func didTapPrimaryButton(in viewController: UIViewController?) {
        viewController?.dismiss(animated: true, completion: { [weak self] in
            self?.printReceiptAction()
        })
    }

    func didTapSecondaryButton(in viewController: UIViewController?) {
        viewController?.dismiss(animated: true)
    }

    func didTapAuxiliaryButton(in viewController: UIViewController?) {}
}

private extension CardPresentModalSuccessWithoutEmail {
    enum Localization {
        static let paymentSuccessful = NSLocalizedString(
            "Payment successful",
            comment: "Label informing users that the payment succeeded. Presented to users when a payment is collected"
        )

        static let printReceipt = NSLocalizedString(
            "Print receipt",
            comment: "Button to print receipts. Presented to users after a payment has been successfully collected"
        )

        static let noThanks = NSLocalizedString(
            "No thanks",
            comment: "Button to dismiss modal overlay. Presented to users after a payment has been successfully collected"
        )
    }
}

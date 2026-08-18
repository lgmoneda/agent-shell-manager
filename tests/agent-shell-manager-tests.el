;;; agent-shell-manager-tests.el --- Tests for agent-shell-manager -*- lexical-binding: t; -*-

(require 'ert)
(require 'agent-shell-manager)

(ert-deftest agent-shell-manager-notification-disabled ()
  (let ((agent-shell-manager-ready-status-notifications nil))
    (should-not
     (agent-shell-manager--should-notify-ready-transition-p
      (current-buffer)))))

(ert-deftest agent-shell-manager-notification-skips-selected-agent ()
  (let ((agent-shell-manager-ready-status-notifications t))
    (cl-letf (((symbol-function 'agent-shell-manager--emacs-active-p)
               (lambda () t))
              ((symbol-function 'agent-shell-manager--buffer-selected-p)
               (lambda (_buffer) t)))
      (should-not
       (agent-shell-manager--should-notify-ready-transition-p
        (current-buffer))))))

(ert-deftest agent-shell-manager-notification-allows-background-agent ()
  (let ((agent-shell-manager-ready-status-notifications t))
    (cl-letf (((symbol-function 'agent-shell-manager--emacs-active-p)
               (lambda () t))
              ((symbol-function 'agent-shell-manager--buffer-selected-p)
               (lambda (_buffer) nil))
              ((symbol-function 'agent-shell-manager--manager-visible-p)
               (lambda () t)))
      (should
       (agent-shell-manager--should-notify-ready-transition-p
        (current-buffer))))))

(ert-deftest agent-shell-manager-notification-allows-inactive-emacs ()
  (let ((agent-shell-manager-ready-status-notifications t))
    (cl-letf (((symbol-function 'agent-shell-manager--emacs-active-p)
               (lambda () nil))
              ((symbol-function 'agent-shell-manager--buffer-selected-p)
               (lambda (_buffer) t)))
      (should
       (agent-shell-manager--should-notify-ready-transition-p
        (current-buffer))))))

(provide 'agent-shell-manager-tests)
;;; agent-shell-manager-tests.el ends here

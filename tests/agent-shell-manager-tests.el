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

(ert-deftest agent-shell-manager-mood-line-annotation-follows-buffer-name ()
  (let* ((format '(((mood-line-segment-buffer-status)
                    " "
                    (mood-line-segment-buffer-name)
                    "  "
                    (mood-line-segment-cursor-position))
                   ((mood-line-segment-major-mode))))
         (updated
          (agent-shell-manager--mood-line-format-with-annotation format)))
    (should
     (equal (car updated)
            '((mood-line-segment-buffer-status)
              " "
              (mood-line-segment-buffer-name)
              (agent-shell-manager--mode-line-annotation)
              "  "
              (mood-line-segment-cursor-position))))
    (should-not (eq updated format))
    (should-not
     (member agent-shell-manager--mood-line-annotation-segment
             (car format)))))

(ert-deftest agent-shell-manager-mood-line-annotation-is-not-duplicated ()
  (let* ((format
          '(((mood-line-segment-buffer-name)
             (agent-shell-manager--mode-line-annotation))
            nil))
         (updated
          (agent-shell-manager--mood-line-format-with-annotation format)))
    (should (equal updated format))))

(ert-deftest agent-shell-manager-mood-line-format-without-buffer-name-is-unchanged ()
  (let* ((format '(((mood-line-segment-major-mode)) nil))
         (updated
          (agent-shell-manager--mood-line-format-with-annotation format)))
    (should (equal updated format))))

(provide 'agent-shell-manager-tests)
;;; agent-shell-manager-tests.el ends here

# PRで修正した範囲だけswiftlintでチェックしてコメントする
github.dismiss_out_of_range_messages

# チケットリンクのチェック
TICKET_URL_PATTERN = %r@https://88-oct.atlassian.net/browse/[a-zA-Z0-9]+-\d+@
unless github.pr_body.match TICKET_URL_PATTERN
    warn("PRの本文に、JIRAチケットのリンクを含めてください")
end

# check milestone set
warn('このPRにマイルストーンを設定してください') if github.pr_json["milestone"].nil?

# check large PR
BIG_PR_LINES = 500
warn("PRが#{BIG_PR_LINES}行を超えています、可能であれば分割を検討してください") if git.lines_of_code > BIG_PR_LINES

# SwiftLint
swiftlint.config_file = 'Example/.swiftlint.yml'
swiftlint.lint_files inline_mode: true

return if status_report[:errors].any?
return if status_report[:warnings].any?
markdown("<p align='center'>:tada:LGTM</p>")

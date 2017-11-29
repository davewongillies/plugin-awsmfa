function __awsmfa_test_expiry
    if test $AWS_SESSION_EXPIRY

        set now (ruby -e "require 'time'; puts Time.now.to_i")
        set expiry (ruby -e "require 'time'; puts Time.iso8601('$AWS_SESSION_EXPIRY').to_i")

        if [ $now -lt $expiry ]
            echo "AWS_SESSION_TOKEN is still valid but will expire at $AWS_SESSION_EXPIRY"
            return 1
        else
            echo "AWS_SESSION_TOKEN expired at $AWS_SESSION_EXPIRY"
        end
    end

    return 0
end

function __awsmfa_clear_variables
    set -gu AWS_SESSION_EXPIRY;    set -Uu AWS_SESSION_EXPIRY
    set -gu AWS_ACCESS_KEY_ID;     set -Uu AWS_ACCESS_KEY_ID
    set -gu AWS_SECRET_ACCESS_KEY; set -Uu AWS_SECRET_ACCESS_KEY
    set -gu AWS_SESSION_TOKEN;     set -Uu AWS_SESSION_TOKEN
end

function awsmfa
    if not type -q aws
        echo "Please install the aws cli before continuing"
    end

    set duration "43200"

    if test (count $argv) -eq 0
        set profile "default"
    else
        set profile $argv[1]
    end

    if not fgrep -q "[$profile]" ~/.aws/credentials
        echo "Please specify a valid profile."
    else

        if __awsmfa_test_expiry
            __awsmfa_clear_variables

            set account (awk "/\[$profile\]/,/^\$/ { if (\$1 == \"account_id\") { print \$3 }}" ~/.aws/credentials)
            set username (awk "/\[$profile\]/,/^\$/ { if (\$1 == \"username\") { print \$3 }}" ~/.aws/credentials)
            set mfarn "arn:aws:iam::$account:mfa/$username"

            echo "Please enter your MFA token for $mfarn:"
            read -l mfa_token

            set aws_cli (aws --profile=$profile sts get-session-token \
            --serial-number="$mfarn" \
            --token-code=$mfa_token \
            --duration-seconds $duration \
            --output text \
            --query \
'Credentials | join (`;`,values({ AccessKeyId: join(``, [`set -Ux AWS_ACCESS_KEY_ID `,AccessKeyId]), SecretAccessKey:join(``, [`set -Ux AWS_SECRET_ACCESS_KEY `,SecretAccessKey]), SessionToken:join(``, [`set -Ux AWS_SESSION_TOKEN `,SessionToken]), Expiration:join(``, [`set -Ux AWS_SESSION_EXPIRY `,Expiration]) }))' )

            fish -c $aws_cli
        end
    end
end

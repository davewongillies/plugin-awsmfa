function __awsmfa_test_expiry
    if test $AWS_SESSION_EXPIRY

        set now (date +'%s')
        set expiry (date -j -f "%FT%TZ" "$AWS_SESSION_EXPIRY" +%s)

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
    set -gu AWS_SECURITY_TOKEN;    set -Uu AWS_SECURITY_TOKEN
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

    if not fgrep -q "[profile $profile]" ~/.aws/config
        echo "Please specify a valid profile."
    else

        if __awsmfa_test_expiry
            __awsmfa_clear_variables 2>/dev/null

            set mfarn (awk "/\[profile $profile\]/,/^\$/ { if (/mfa_serial/) { print \$3 }}" ~/.aws/config)
            set account (echo $mfarn | awk -F[:/] "{ print \$5}")
            set username (echo $mfarn | awk -F[:/] "{ print \$7}")

            echo "Please enter your AWS MFA token for $mfarn:"
            read -p "set_color yellow; echo -n token; set_color normal; echo '> '" -l mfa_token

            set aws_cli (aws --profile=$profile sts get-session-token \
            --serial-number="$mfarn" \
            --token-code=$mfa_token \
            --duration-seconds $duration \
            --output text \
            --query \
'Credentials | join (`;`,values({ AccessKeyId: join(``, [`set -Ux AWS_ACCESS_KEY_ID `,AccessKeyId]), SecretAccessKey:join(``, [`set -Ux AWS_SECRET_ACCESS_KEY `,SecretAccessKey]), SessionToken:join(``, [`set -Ux AWS_SESSION_TOKEN `,SessionToken]), SessionToken:join(``, [`set -Ux AWS_SECURITY_TOKEN `,SessionToken]), Expiration:join(``, [`set -Ux AWS_SESSION_EXPIRY `,Expiration]) }))' )
            test $status -eq 0; and fish -c $aws_cli
        end
    end
end

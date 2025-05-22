Config = {}
Config.WEBHOOK_URL = ""
Config.OpenMenu = {
    Command = {
        Enable = true, --true or false
        Name = "reference",
    }
}
Config.Reward = {
    Owner = 1000, -- Amount of money the user will receive for using their own code
    Referred = 500, -- Amount of money the user will receive for using someone else's code
}

Config.Language = {
    NoCode = "Code does not exist",
    AlreadyClaimed = "You have already claimed your code",
    ClaimSuccess = "Claim successful",
    CodeUsed = "Code already used",
    NoOwnCode = "You cannot use your own code",
    -----Webhook-----
    WebhookUsername = "Reference Logs",
    WebhookTitle = "Claim Code",
    WebhookDescription = "Referral Code",
    WebhookColor = 16777215,
}
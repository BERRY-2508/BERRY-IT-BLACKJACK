# Berry Black Jack with Currency System

$again = $null

# Starting balance
$balance = 100
$bet = 0
$lastBet = 0  # Store the last bet amount
$loanAmount = 0
$interestRate = 0.05  # 5% interest on loan

# Use text representation of suits
$deck = "A♠", "A♥", "A♣", "A♦", "2♠", "2♥", "2♣", "2♦", "3♠", "3♥", "3♣", "3♦", "4♠", "4♥", "4♣", "4♦",
"5♠", "5♥", "5♣", "5♦", "6♠", "6♥", "6♣", "6♦", "7♠", "7♥", "7♣", "7♦", "8♠", "8♥", "8♣", "8♦",
"9♠", "9♥", "9♣", "9♦", "10♠", "10♥", "10♣", "10♦", "J♠", "J♥", "J♣", "J♦", "Q♠", "Q♥", "Q♣",
"Q♦", "K♠", "K♥", "K♣", "K♦"

$numbers = "2", "3", "4", "5", "6", "7", "8", "9"
$tens = "J", "Q", "K", "1"
$options = "a", "s", "d", "f"  # Removed "r" for rebet option

# Taunts for when the player runs out of money
$taunts = @(
    "Ha! You think you can win? Guess not!",
    "Well, that was quick... better luck next time!",
    "Are you sure you're ready for this?",
    "Looks like you're out of luck... or just bad at this.",
    "Maybe try a simpler game, like Tic-Tac-Toe?",
    "Oops! Did you just forget to check your wallet?",
    "All out of Chips? What will you do now?",
    "Looks like you're not the master of BlackJack after all!"
)

# Function to check if the player has a Blackjack
function Check-Blackjack {
    param (
        [array]$cards
    )
    
    # Check if the hand contains an Ace and a 10-point card (Jack, Queen, King, 10)
    if (($cards[0] -eq "A" -and $cards[2] -in $tens) -or ($cards[2] -eq "A" -and $cards[0] -in $tens)) {
        return $true
    }
    return $false
}

# Game loop
while ($again -ne "n" -and $balance -gt 0) {
    cls  # Clear the screen before showing the balance

    # Display current balance before each round
    Write-Host "`n───────────────────────────────────────────────────"
    Write-Host ("Current balance: $($balance) Chips") -ForegroundColor Green
    Write-Host "───────────────────────────────────────────────────"

    # Check if the balance is below 5 and prompt for a loan if no loan has been taken
    if ($balance -lt 5 -and $loanAmount -eq 0) {
        Write-Host "`n───────────────────────────────────────────────────"
        Write-Host "Looks like you’re out of cash... but don't worry!" 
        Write-Host "We’ve got you covered with a loan of 50 Chips."
        Write-Host "Accept the loan, or walk away from this casino."
        Write-Host "`n───────────────────────────────────────────────────"

        # Prompt for first loan
        $firstLoanResponse = Read-Host -Prompt "Do you want to take a loan of 50 Chips? (Y/N)"
        if ($firstLoanResponse -eq "y" -or $firstLoanResponse -eq "Y") {
            $loanAmount += 50  # Add to cumulative loan total
            $balance += 50  # Add loan to balance
            Write-Host "`nYou have taken a loan of 50 Chips."
            Write-Host "`nYour new balance is: $($balance) Chips"
            Write-Host "`nYou will be charged 5% interest on your loan every round."
        }
        else {
            break  # End the game if the player refuses the loan
        }
    }

    # Apply Interest on Cumulative Loan
    if ($loanAmount -gt 0) {
        $interest = [math]::Round($loanAmount * $interestRate, 2)
        $loanAmount += $interest
        $balance -= $interest
        Write-Host "`nInterest charged: $($interest) Chips." -ForegroundColor DarkYellow
        Write-Host "Loan balance is now: $($loanAmount) Chips." -ForegroundColor DarkRed
    }

    # Repayment feature: Prompt to repay loan if the player has a loan
    if ($loanAmount -gt 0) {
        $repaymentOption = Read-Host -Prompt "Do you want to repay your loan of $($loanAmount) Chips? (Y/N)"
        if ($repaymentOption -eq "y" -or $repaymentOption -eq "Y") {
            if ($balance -ge $loanAmount) {
                $balance -= $loanAmount  # Repay loan
                Write-Host "`nYou have repaid your loan. Your new balance is: $($balance) Chips" -ForegroundColor Green
                $loanAmount = 0  # Reset loan balance
            }
            else {
                Write-Host "`nYou don't have enough Chips to repay your loan!" -ForegroundColor Red
            }
        }
    }

    # Ask for a valid bet amount (Minimum bet is 5 Chips and must be in multiples of 5)
    $bet = 0
    while ($bet -lt 5 -or $bet -gt $balance -or $bet % 5 -ne 0) {
        $betInput = Read-Host -Prompt "Enter your bet (you have $($balance) Chips, minimum bet is 5 Chips and must be in multiples of 5):"
        
        # Ensure the input is a valid number and greater than or equal to 5
        if ($betInput -match '^\d+$') {
            $bet = [int]$betInput
            if ($bet -lt 5) {
                Write-Host "Bet must be at least 5 Chips."
            }
            elseif ($bet % 5 -ne 0) {
                Write-Host "Bet must be in multiples of 5 Chips."
            }
            elseif ($bet -gt $balance) {
                Write-Host "You cannot bet more than your balance!" -ForegroundColor Red
            }
        }
        else {
            Write-Host "Please enter a valid number for your bet." -ForegroundColor Red
        }
    }

    # Store the last bet amount
    $lastBet = $bet

    # Simulating the gameplay with the deck, dealer's hand, and player's hand
    $deal = get-random -InputObject $deck -Count 17
    $dealer = "Dealer: " + $deal[3]
    $you = "You: " + $deal[0] + " " + $deal[2]
    $cards = @($deal[0], $deal[2])
    $again = $null
    $cardvalue = @{}

    0..16 | % {if ($deal[$_][0] -in $numbers) {($cardvalue[$_] = $deal[$_][0]) / 1}
        elseif ($deal[$_][0] -in $tens) {$cardvalue[$_] = 10}
        elseif ($deal[$_][0] -eq "A") {$cardvalue[$_] = 11}}

    $youtotal = (([string]$cardvalue[0] / 1) + ([string]$cardvalue[2] / 1))

    # Check for Blackjack (Ace + 10-point card)
    if (Check-Blackjack $cards) {
        Write-Host "`nYou win with a Blackjack! Payout is 1.5x your bet."
        $balance += [math]::Round($bet * 1.5, 2)  # 1.5x payout for Blackjack
        Write-Host "`nYour new balance is: $($balance) Chips" -ForegroundColor Green
        continue  # Skip the rest of the round, player already won
    }

    # Dealer's first two cards
    $dealercards = @($deal[1], $deal[3])
    $dealertotal = ([string]$cardvalue[1] / 1) + ([string]$cardvalue[3] / 1)

    # Check if the dealer has a Blackjack
    if (Check-Blackjack $dealercards) {
        Write-Host "`nThe dealer has a Blackjack. It's a tie (Push)." -ForegroundColor Yellow
        continue  # Skip the rest of the round, it's a push
    }

    cls  # Clear the screen at the start of each round

    Write-Host "`n───────────────────────────────────────────────────"
    Write-Host "$dealer" -ForegroundColor DarkRed  # Dealer's cards in DarkRed
    Write-Host "───────────────────────────────────────────────────"

    Write-Host "$you         Value: $youtotal" -ForegroundColor DarkCyan  # Player's hand in DarkCyan
    Write-Host "───────────────────────────────────────────────────"

    $move = $null
    $n = 4

    while ($youtotal -lt 22 -and $move -ne 's') {
        $move = $null

        while ($move -notin $options) {
            $move = Read-Host -Prompt "`nType 'a' to Hit, 's' to Stand"

            if ($move -eq 'a') {
                cls  # Clear the screen each time the player hits
                $you = $you + " " + $deal[$n]
                $youtotal = ($youtotal) + ([string]$cardvalue[$n] / 1)
                $n++ 
                cls  # Clear the screen after the new card is dealt

                Write-Host "`n───────────────────────────────────────────────────"
                Write-Host "$dealer" -ForegroundColor DarkRed
                Write-Host "───────────────────────────────────────────────────"
                Write-Host "$you        Value: $youtotal" -ForegroundColor DarkCyan
                Write-Host "───────────────────────────────────────────────────"

            }
            elseif ($move -eq 's') {
                $dealer = $deal[1] + " " + $deal[3] 
                $dealertotal = (([string]$cardvalue[1] / 1) + ([string]$cardvalue[3] / 1))

                while ($dealertotal -lt 17) {
                    $dealer = $dealer + " " + $deal[$n]
                    $dealertotal = ($dealertotal) + ([string]$cardvalue[$n] / 1)
                    $n++ 
                    cls  # Clear the screen after each dealer card is dealt

                    Write-Host "`n───────────────────────────────────────────────────"
                    Write-Host "$dealer" -ForegroundColor DarkRed
                    Write-Host "───────────────────────────────────────────────────"
                    Write-Host "$you        Value: $youtotal" -ForegroundColor DarkCyan
                    Write-Host "───────────────────────────────────────────────────"
                }
                cls

                # Outcome decision
                if ($youtotal -gt $dealertotal -or $dealertotal -gt 21) {
                    cls
                    Write-Host "`n───────────────────────────────────────────────────"
                    Write-Host "$dealer        Value: $dealertotal" -ForegroundColor DarkRed
                    Write-Host "───────────────────────────────────────────────────"
                    Write-Host "$you        Value: $youtotal" -ForegroundColor DarkCyan
                    Write-Host "───────────────────────────────────────────────────"
                    Write-Host "`nVictory! You win $($bet) Chips!" -ForegroundColor Green
                    Write-Host "───────────────────────────────────────────────────"
                    $balance += $bet  # Increase balance if you win
                }
                elseif ($youtotal -eq $dealertotal -and $dealertotal -le 21) {
                    cls
                    Write-Host "`n───────────────────────────────────────────────────"
                    Write-Host "$dealer        Value: $dealertotal" -ForegroundColor DarkRed
                    Write-Host "───────────────────────────────────────────────────"
                    Write-Host "$you        Value: $youtotal" -ForegroundColor DarkCyan
                    Write-Host "───────────────────────────────────────────────────"
                    Write-Host "`nDraw! It's a tie!" -ForegroundColor Yellow
                    Write-Host "───────────────────────────────────────────────────"
                }
                else {
                    cls
                    Write-Host "`n───────────────────────────────────────────────────"
                    Write-Host "$dealer        Value: $dealertotal" -ForegroundColor Red
                    Write-Host "───────────────────────────────────────────────────"
                    Write-Host "$you        Value: $youtotal" -ForegroundColor Green
                    Write-Host "───────────────────────────────────────────────────"
                    Write-Host "`nBetter Luck Next Time! You lose $($bet) Chips." -ForegroundColor Red
                    Write-Host "───────────────────────────────────────────────────"
                    $balance -= $bet  # Decrease balance if you lose
                }
            }
            else {Write-Host "Invalid Command" -ForegroundColor Red}
        }
    }

    if ($youtotal -gt 21) {
        cls
        Write-Host "`n───────────────────────────────────────────────────"
        Write-Host "$dealer        Value: $dealertotal" -ForegroundColor DarkRed
        Write-Host "───────────────────────────────────────────────────"
        Write-Host "$you        Value: $youtotal" -ForegroundColor DarkCyan
        Write-Host "───────────────────────────────────────────────────"
        Write-Host "`nBetter Luck Next Time! You've busted! You lose $($bet) Chips." -ForegroundColor Red
        Write-Host "───────────────────────────────────────────────────"
        $balance -= $bet  # Decrease balance if you bust
    }

    # Display updated balance
    Write-Host "`nYour current balance is: $($balance) Chips" -ForegroundColor Green

    # Check if player has no more money
    if ($balance -lt 5) {
        # Display a random taunt
        $taunt = Get-Random -InputObject $taunts
        Write-Host "`n$taunt"
        Write-Host "`nYou have less than 5 Chips left. Game over!"

        # Offer the option to take a loan
        $loanResponse = Read-Host -Prompt "Would you like to take a loan to continue playing? (Y/N)"
        if ($loanResponse -eq "y" -or $loanResponse -eq "Y") {
            $loanAmount += 50  # Add to cumulative loan total
            $balance += 50  # Add loan to balance
            Write-Host "`nYou have taken a loan of $($loanAmount) Chips."
            Write-Host "`nYour new balance is: $($balance) Chips"
            Write-Host "`nYou will be charged 5% interest on your loan every round."
        }
        else {
            break  # End the game if the player refuses the loan
        }
    }

    # Punishment: Add interest on loan after each round
    if ($loanAmount -gt 0) {
        $interest = [math]::Round($loanAmount * $interestRate, 2)
        $loanAmount += $interest
        $balance -= $interest
        Write-Host "`nInterest charged: $($interest) Chips." -ForegroundColor DarkYellow
        Write-Host "Loan balance is now: $($loanAmount) Chips." -ForegroundColor DarkRed
    }

    # Ask if they want to play again
    while ($again -ne "y" -and $again -ne "n") {
        $again = Read-Host -Prompt "`nPlay Again? (Y/N)"
    }
}

cls
Write-Host "`nThanks for playing! Your final balance is: $($balance) Chips" -ForegroundColor Green

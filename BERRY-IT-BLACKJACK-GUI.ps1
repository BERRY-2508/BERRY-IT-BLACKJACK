# BERRY IT Blackjack GUI — Windows PowerShell 5.1, Windows Forms.
# Virtual chips only. Original terminal game remains unchanged.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$bg = [System.Drawing.ColorTranslator]::FromHtml('#0B0B0E')
$panel = [System.Drawing.ColorTranslator]::FromHtml('#1B1B20')
$red = [System.Drawing.ColorTranslator]::FromHtml('#FF3C3C')
$white = [System.Drawing.ColorTranslator]::FromHtml('#F4F4F4')
$muted = [System.Drawing.ColorTranslator]::FromHtml('#ACAAB2')
$green = [System.Drawing.ColorTranslator]::FromHtml('#68C8A1')

$form = New-Object System.Windows.Forms.Form
$form.Text = 'BERRY IT | Blackjack'
$form.ClientSize = New-Object System.Drawing.Size(900,670)
$form.MinimumSize = New-Object System.Drawing.Size(760,630)
$form.StartPosition = 'CenterScreen'
$form.BackColor = $bg
$form.ForeColor = $white
$form.Font = New-Object System.Drawing.Font('Segoe UI',11)
$form.AutoScaleMode = 'Dpi'

function Add-Label($text,$x,$y,$w,$h,$size,$color,$bold=$false) {
    $l = New-Object System.Windows.Forms.Label
    $l.Text=$text; $l.Location=New-Object System.Drawing.Point($x,$y)
    $l.Size=New-Object System.Drawing.Size($w,$h)
    $style = if($bold){[System.Drawing.FontStyle]::Bold}else{[System.Drawing.FontStyle]::Regular}
    $l.Font=New-Object System.Drawing.Font('Segoe UI',$size,$style)
    $l.ForeColor=$color; $l.BackColor=$bg; $l.TextAlign='MiddleCenter'
    $form.Controls.Add($l); return $l
}
function Add-Button($text,$x,$y,$w,$onClick) {
    $b=New-Object System.Windows.Forms.Button
    $b.Text=$text; $b.Location=New-Object System.Drawing.Point($x,$y)
    $b.Size=New-Object System.Drawing.Size($w,44)
    $b.FlatStyle='Flat'; $b.FlatAppearance.BorderSize=0
    $b.BackColor=$panel; $b.ForeColor=$white
    $b.Font=New-Object System.Drawing.Font('Segoe UI',11,[System.Drawing.FontStyle]::Bold)
    $b.Add_Click($onClick)
    $form.Controls.Add($b); return $b
}
$null=Add-Label 'B E R R Y   I T' 0 13 900 37 22 $red $true
$null=Add-Label 'B L A C K J A C K' 0 48 900 29 14 $white $true
$null=Add-Label 'CONSULT   •   SECURE   •   MANAGE   •   GROW' 0 80 900 22 9 $muted
$balanceLabel=Add-Label 'BALANCE: 100 CHIPS' 25 115 280 32 15 $white $true
$betLabel=Add-Label 'BET: 10 CHIPS' 640 115 230 32 14 $red $true
$dealerTotalLabel=Add-Label 'DEALER  |  TOTAL: --' 40 167 820 25 12 $muted $true
$dealerArea=New-Object System.Windows.Forms.FlowLayoutPanel
$dealerArea.Location=New-Object System.Drawing.Point(35,196)
$dealerArea.Size=New-Object System.Drawing.Size(830,100)
$dealerArea.BackColor=$bg; $dealerArea.WrapContents=$false; $dealerArea.AutoScroll=$true
$form.Controls.Add($dealerArea)
$playerTotalLabel=Add-Label 'YOUR HAND  |  TOTAL: --' 40 313 820 25 12 $muted $true
$playerArea=New-Object System.Windows.Forms.FlowLayoutPanel
$playerArea.Location=New-Object System.Drawing.Point(35,341)
$playerArea.Size=New-Object System.Drawing.Size(830,100)
$playerArea.BackColor=$bg; $playerArea.WrapContents=$false; $playerArea.AutoScroll=$true
$form.Controls.Add($playerArea)
$statusLabel=Add-Label 'Choose your bet and press DEAL.' 35 460 830 42 15 $white $true
$null=Add-Label 'BET' 164 524 75 32 11 $muted $true
$betInput=New-Object System.Windows.Forms.NumericUpDown
$betInput.Location=New-Object System.Drawing.Point(240,527)
$betInput.Size=New-Object System.Drawing.Size(100,30)
$betInput.Minimum=5; $betInput.Maximum=100; $betInput.Increment=5; $betInput.Value=10
$betInput.BackColor=$panel; $betInput.ForeColor=$white
$form.Controls.Add($betInput)
$state=@{ Balance=100; Bet=0; Deck=@(); Player=@(); Dealer=@(); InRound=$false; Finished=$false }

function Get-Score($hand) {
    $score=0; $aces=0
    foreach($card in $hand) {
        $r=$card.Split(':')[0]
        if($r -eq 'A'){$score+=11;$aces++}
        elseif($r -in @('J','Q','K')){$score+=10}
        else{$score += [int]$r}
    }
    while($score -gt 21 -and $aces -gt 0){$score-=10;$aces--}
    return $score
}
function Draw-Card {
    $last=$state.Deck.Count-1
    $c=$state.Deck[$last]
    if($last -eq 0){$state.Deck=@()}else{$state.Deck=@($state.Deck[0..($last-1)])}
    return $c
}
function Center-Hand($container) {
    # FlowLayoutPanel aligns to the left by default. Centre its card row after every draw.
    $cardWidth=82
    $totalWidth=$container.Controls.Count*$cardWidth
    $left=[Math]::Max(0,[int](($container.ClientSize.Width-$totalWidth)/2))
    $container.Padding=New-Object System.Windows.Forms.Padding($left,0,0,0)
}
function Update-Totals {
    if($state.Player.Count -gt 0){
        $playerTotalLabel.Text="YOUR HAND  |  TOTAL: $(Get-Score $state.Player)"
    }else{$playerTotalLabel.Text='YOUR HAND  |  TOTAL: --'}
    if($state.Dealer.Count -eq 0){$dealerTotalLabel.Text='DEALER  |  TOTAL: --'}
    elseif($state.InRound){
        $shown=Get-Score @($state.Dealer[0])
        $dealerTotalLabel.Text="DEALER  |  SHOWING: $shown  (+ hidden card)"
    }else{
        $dealerTotalLabel.Text="DEALER  |  TOTAL: $(Get-Score $state.Dealer)"
    }
}
function Draw-Hand($container,$hand,$hideHole) {
    $container.Controls.Clear()
    for($i=0;$i -lt $hand.Count;$i++) {
        $card=$hand[$i]
        $box=New-Object System.Windows.Forms.Label
        $box.Size=New-Object System.Drawing.Size(72,88)
        $box.Margin=New-Object System.Windows.Forms.Padding(5)
        $box.BackColor=[System.Drawing.Color]::White
        $box.ForeColor=[System.Drawing.Color]::Black
        $box.BorderStyle='FixedSingle'
        $box.TextAlign='MiddleCenter'
        $box.Font=New-Object System.Drawing.Font('Segoe UI',19,[System.Drawing.FontStyle]::Bold)
        if($hideHole -and $i -eq 1){
            $box.Text='★'; $box.BackColor=$red; $box.ForeColor=$white
        }else{
            $parts=$card.Split(':')
            $suit=$parts[1]; $box.Text=$parts[0]+"`r`n"+$suit
            if($suit -in @('♥','♦')){$box.ForeColor=$red}
        }
        $container.Controls.Add($box)
    }
    Center-Hand $container
}
function Refresh-Table {
    $balanceLabel.Text="BALANCE: $($state.Balance) CHIPS"
    $betLabel.Text="BET: $($state.Bet) CHIPS"
    Draw-Hand $dealerArea $state.Dealer $state.InRound
    Draw-Hand $playerArea $state.Player $false
    Update-Totals
    $hitButton.Enabled=$state.InRound
    $standButton.Enabled=$state.InRound
    $dealButton.Enabled=(-not $state.InRound)
    $betInput.Enabled=(-not $state.InRound)
    if($state.Balance -lt 5 -and -not $state.InRound) {
        $dealButton.Enabled=$false
        $statusLabel.Text="Out of chips. Press RESET BANKROLL to start again."
    }
    if(-not $state.InRound){$betInput.Maximum=[Math]::Max(5,$state.Balance)}
}
function End-Round($result) {
    $state.InRound=$false
    $ps=Get-Score $state.Player
    $ds=Get-Score $state.Dealer
    if($result -eq 'win'){$state.Balance += $state.Bet; $statusLabel.Text="YOU WIN!  +$($state.Bet) chips  |  $ps vs $ds";$statusLabel.ForeColor=$green}
    elseif($result -eq 'blackjack'){$gain=[int][Math]::Round($state.Bet*1.5,0,[MidpointRounding]::AwayFromZero);$state.Balance += $gain;$statusLabel.Text="BLACKJACK!  +$gain chips";$statusLabel.ForeColor=$green}
    elseif($result -eq 'lose'){$state.Balance -= $state.Bet;$statusLabel.Text="DEALER WINS  -$($state.Bet) chips  |  $ps vs $ds";$statusLabel.ForeColor=$red}
    else{$statusLabel.Text="PUSH — bet returned  |  $ps vs $ds";$statusLabel.ForeColor=$white}
    Refresh-Table
}
$dealButton=Add-Button 'DEAL' 360 520 112 {
    $bet=[int]$betInput.Value
    if($bet -gt $state.Balance -or $bet -lt 5 -or $bet%5 -ne 0) {
        [System.Windows.Forms.MessageBox]::Show('Bet must be a multiple of 5 and within your balance.');return
    }
    $ranks=@('A','2','3','4','5','6','7','8','9','10','J','Q','K')
    $suits=@('♠','♥','♣','♦')
    $deck=@(foreach($suit in $suits){foreach($rank in $ranks){"${rank}:${suit}"}})
    $state.Deck=@($deck | Get-Random -Count 52)
    $state.Player=@((Draw-Card),(Draw-Card))
    $state.Dealer=@((Draw-Card),(Draw-Card))
    $state.Bet=$bet; $state.InRound=$true
    $statusLabel.ForeColor=$white; $statusLabel.Text='Your turn — HIT or STAND'
    $ps=Get-Score $state.Player
    $ds=Get-Score $state.Dealer
    if($ps -eq 21 -or $ds -eq 21) {
        if($ps -eq 21 -and $ds -eq 21){End-Round 'push'}
        elseif($ps -eq 21){End-Round 'blackjack'}
        else{End-Round 'lose'}
    }else{Refresh-Table}
}
$hitButton=Add-Button 'HIT' 485 520 110 {
    $state.Player=@($state.Player)+@(Draw-Card)
    if((Get-Score $state.Player) -gt 21){End-Round 'lose'}
    else {Refresh-Table}
}
$standButton=Add-Button 'STAND' 607 520 110 {
    while((Get-Score $state.Dealer) -lt 17){$state.Dealer=@($state.Dealer)+@(Draw-Card)}
    $player=Get-Score $state.Player; $dealer=Get-Score $state.Dealer
    if($dealer -gt 21 -or $player -gt $dealer){End-Round 'win'}
    elseif($player -eq $dealer){End-Round 'push'}
    else{End-Round 'lose'}
}
$resetButton=Add-Button 'RESET BANKROLL' 360 582 235 {
    $reply=[System.Windows.Forms.MessageBox]::Show('Reset your virtual balance to 100 chips?','Reset bankroll','YesNo','Question')
    if($reply -ne 'Yes'){return}
    $state.Balance=100; $state.Bet=0; $state.InRound=$false
    $state.Player=@(); $state.Dealer=@()
    $betInput.Maximum=100; $betInput.Value=10; $statusLabel.ForeColor=$white
    $statusLabel.Text='Bankroll reset. Choose a bet to play.'
    Refresh-Table
}
$null=Add-Label 'VIRTUAL CHIPS ONLY  •  NO REAL-MONEY GAMBLING' 0 637 900 22 9 $muted
Refresh-Table
[void]$form.ShowDialog()

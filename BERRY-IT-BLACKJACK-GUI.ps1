# BERRY IT Blackjack GUI — Windows PowerShell 5.1, Windows Forms.
# Virtual chips only. Original terminal game remains unchanged.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$bg = [System.Drawing.ColorTranslator]::FromHtml('#0B0B0E')
$panel = [System.Drawing.ColorTranslator]::FromHtml('#1B1B20')
$surface = [System.Drawing.ColorTranslator]::FromHtml('#141417')
$line = [System.Drawing.ColorTranslator]::FromHtml('#38383E')
$red = [System.Drawing.ColorTranslator]::FromHtml('#FF3C3C')
$white = [System.Drawing.ColorTranslator]::FromHtml('#F4F4F4')
$muted = [System.Drawing.ColorTranslator]::FromHtml('#ACAAB2')
$green = [System.Drawing.ColorTranslator]::FromHtml('#68C8A1')

$form = New-Object System.Windows.Forms.Form
$form.Text = 'BERRY IT | Blackjack — Modern Table v2'
$form.ClientSize = New-Object System.Drawing.Size(980,850)
$form.MinimumSize = New-Object System.Drawing.Size(830,770)
$form.StartPosition = 'CenterScreen'
$form.BackColor = $bg
$form.ForeColor = $white
$form.Font = New-Object System.Drawing.Font('Segoe UI',11)
$form.AutoScaleMode = 'Dpi'
$form.FormBorderStyle = 'Sizable'
$form.MaximizeBox = $true

function Add-Label($text,$x,$y,$w,$h,$size,$color,$bold=$false) {
    $l = New-Object System.Windows.Forms.Label
    $l.Text=$text; $l.Location=New-Object System.Drawing.Point($x,$y)
    $l.Size=New-Object System.Drawing.Size($w,$h)
    $style = if($bold){[System.Drawing.FontStyle]::Bold}else{[System.Drawing.FontStyle]::Regular}
    $l.Font=New-Object System.Drawing.Font('Segoe UI',$size,$style)
    $l.ForeColor=$color; $l.BackColor=$bg; $l.TextAlign='MiddleCenter'; $l.AutoEllipsis=$true
    $form.Controls.Add($l); return $l
}
function Add-Button($text,$x,$y,$w,$onClick) {
    $b=New-Object System.Windows.Forms.Button
    $b.Text=$text; $b.Location=New-Object System.Drawing.Point($x,$y)
    $b.Size=New-Object System.Drawing.Size($w,44)
    $b.FlatStyle='Flat'; $b.FlatAppearance.BorderSize=1; $b.FlatAppearance.BorderColor=$line
    $b.BackColor=$panel; $b.ForeColor=$white; $b.Cursor='Hand'
    $b.Font=New-Object System.Drawing.Font('Segoe UI',11,[System.Drawing.FontStyle]::Bold)
    $b.Add_Click($onClick)
    $form.Controls.Add($b); return $b
}
$null=Add-Label 'B E R R Y   I T' 0 13 900 37 22 $red $true
$null=Add-Label 'B L A C K J A C K' 0 48 900 29 14 $white $true
$null=Add-Label 'CONSULT   •   SECURE   •   MANAGE   •   GROW' 0 80 900 22 9 $muted
$balanceLabel=Add-Label 'BALANCE: 100 CHIPS' 25 115 280 32 15 $white $true
$betLabel=Add-Label 'BET: 0 CHIPS' 640 115 230 32 14 $red $true
$dealerTotalLabel=Add-Label 'DEALER  |  TOTAL: --' 40 167 820 25 12 $muted $true
$dealerArea=New-Object System.Windows.Forms.FlowLayoutPanel
$dealerArea.Location=New-Object System.Drawing.Point(35,196)
$dealerArea.Size=New-Object System.Drawing.Size(830,100)
$dealerArea.BackColor=$surface; $dealerArea.WrapContents=$false; $dealerArea.AutoScroll=$true; $dealerArea.BorderStyle='FixedSingle'
$form.Controls.Add($dealerArea)
$playerTotalLabel=Add-Label 'YOUR HAND  |  TOTAL: --' 40 313 820 25 12 $muted $true
$playerArea=New-Object System.Windows.Forms.FlowLayoutPanel
$playerArea.Location=New-Object System.Drawing.Point(35,341)
$playerArea.Size=New-Object System.Drawing.Size(830,100)
$playerArea.BackColor=$surface; $playerArea.WrapContents=$false; $playerArea.AutoScroll=$true; $playerArea.BorderStyle='FixedSingle'
$form.Controls.Add($playerArea)
$statusLabel=Add-Label 'Choose your bet and press DEAL.' 35 460 830 42 15 $white $true
$null=Add-Label 'CLICK CHIPS TO PLACE YOUR BET' 0 503 900 24 11 $muted $true
$state=@{ Balance=100; Bet=0; SelectedBet=0; Deck=@(); Player=@(); Dealer=@(); InRound=$false; Finished=$false }
$chipButtons=@()
$chipValues=@(5,10,25,50)
$chipColors=@('#555E6B','#146E82','#AB651C','#B4203B')
for($i=0;$i -lt $chipValues.Count;$i++){
    $chip=New-Object System.Windows.Forms.Button
    $chip.Text=[string]$chipValues[$i]
    $chip.Tag=$chipValues[$i]
    $chip.Size=New-Object System.Drawing.Size(66,66)
    $chip.Location=New-Object System.Drawing.Point((238+$i*91),534)
    $chip.Cursor='Hand'
    $chip.FlatStyle='Flat'; $chip.FlatAppearance.BorderSize=2
    $chip.FlatAppearance.BorderColor=$white
    $chip.BackColor=[System.Drawing.ColorTranslator]::FromHtml($chipColors[$i])
    $chip.ForeColor=$white
    $chip.Font=New-Object System.Drawing.Font('Segoe UI',15,[System.Drawing.FontStyle]::Bold)
    $circle=New-Object System.Drawing.Drawing2D.GraphicsPath
    $circle.AddEllipse(0,0,65,65)
    $chip.Region=[System.Drawing.Region]::new($circle)
    $circle.Dispose()
    $chip.Add_Click({
        if($state.InRound){return}
        $amount=[int]$this.Tag
        if(($state.SelectedBet+$amount) -le $state.Balance){
            $state.SelectedBet += $amount
            $statusLabel.ForeColor=$white
            $statusLabel.Text="Bet selected: $($state.SelectedBet) chips. Press DEAL to play."
        }else{
            $statusLabel.ForeColor=$red
            $statusLabel.Text="Not enough chips to add $amount to your bet."
        }
        Refresh-Table
    })
    $form.Controls.Add($chip)
    $chipButtons+= $chip
}
$clearBetButton=Add-Button 'CLEAR BET' 603 545 145 {
    if($state.InRound){return}
    $state.SelectedBet=0
    $statusLabel.ForeColor=$white
    $statusLabel.Text='Select chips to place a bet.'
    Refresh-Table
}

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
    $displayBet=if($state.InRound){$state.Bet}else{$state.SelectedBet}
    $betLabel.Text="BET: $displayBet CHIPS"
    Draw-Hand $dealerArea $state.Dealer $state.InRound
    Draw-Hand $playerArea $state.Player $false
    Update-Totals
    $hitButton.Enabled=$state.InRound
    $standButton.Enabled=$state.InRound
    $dealButton.Enabled=(-not $state.InRound -and $state.SelectedBet -ge 5 -and $state.SelectedBet -le $state.Balance)
    foreach($chip in $chipButtons){$chip.Enabled=(-not $state.InRound)}
    $clearBetButton.Enabled=(-not $state.InRound)
    if($state.Balance -lt 5 -and -not $state.InRound) {
        $dealButton.Enabled=$false
        $statusLabel.Text="Out of chips. Press RESET BANKROLL to start again."
    }
    # Betting is controlled by the clickable chips; no numeric input is used.
}
function End-Round($result) {
    $state.InRound=$false
    $ps=Get-Score $state.Player
    $ds=Get-Score $state.Dealer
    if($result -eq 'win'){$state.Balance += $state.Bet; $statusLabel.Text="YOU WIN!  +$($state.Bet) chips  |  $ps vs $ds";$statusLabel.ForeColor=$green}
    elseif($result -eq 'blackjack'){$gain=[int][Math]::Round($state.Bet*1.5,0,[MidpointRounding]::AwayFromZero);$state.Balance += $gain;$statusLabel.Text="BLACKJACK!  +$gain chips";$statusLabel.ForeColor=$green}
    elseif($result -eq 'lose'){$state.Balance -= $state.Bet;$statusLabel.Text="DEALER WINS  -$($state.Bet) chips  |  $ps vs $ds";$statusLabel.ForeColor=$red}
    else{$statusLabel.Text="PUSH — bet returned  |  $ps vs $ds";$statusLabel.ForeColor=$white}
    $state.SelectedBet=0
    Refresh-Table
}
$dealButton=Add-Button 'DEAL' 265 620 112 {
    $bet=[int]$state.SelectedBet
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
$hitButton=Add-Button 'HIT' 395 620 110 {
    $state.Player=@($state.Player)+@(Draw-Card)
    if((Get-Score $state.Player) -gt 21){End-Round 'lose'}
    else {Refresh-Table}
}
$standButton=Add-Button 'STAND' 523 620 110 {
    while((Get-Score $state.Dealer) -lt 17){$state.Dealer=@($state.Dealer)+@(Draw-Card)}
    $player=Get-Score $state.Player; $dealer=Get-Score $state.Dealer
    if($dealer -gt 21 -or $player -gt $dealer){End-Round 'win'}
    elseif($player -eq $dealer){End-Round 'push'}
    else{End-Round 'lose'}
}
$resetButton=Add-Button 'RESET BANKROLL' 333 676 235 {
    $reply=[System.Windows.Forms.MessageBox]::Show('Reset your virtual balance to 100 chips?','Reset bankroll','YesNo','Question')
    if($reply -ne 'Yes'){return}
    $state.Balance=100; $state.Bet=0; $state.SelectedBet=0; $state.InRound=$false
    $state.Player=@(); $state.Dealer=@()
    $statusLabel.ForeColor=$white
    $statusLabel.Text='Bankroll reset. Choose a bet to play.'
    Refresh-Table
}
$null=Add-Label 'VIRTUAL CHIPS ONLY  •  NO REAL-MONEY GAMBLING' 0 730 900 22 9 $muted
# Responsive layout: centre cards, chips and actions at every window size.
# Position elements using the current client dimensions rather than fixed initial pixels.
function Update-Layout {
    $w=$form.ClientSize.Width
    $h=$form.ClientSize.Height
    $mid=[int]($w/2)
    $pad=36
    $tableWidth=$w-($pad*2)

    $form.Controls[0].SetBounds(0,13,$w,39)
    $form.Controls[1].SetBounds(0,52,$w,28)
    $form.Controls[2].SetBounds(0,84,$w,22)
    $balanceLabel.Location=New-Object System.Drawing.Point($pad,131)
    $balanceLabel.Width=[int](($w/2)-$pad)
    $balanceLabel.TextAlign='MiddleLeft'
    $betLabel.Location=New-Object System.Drawing.Point($mid,131)
    $betLabel.Width=[int](($w/2)-$pad)
    $betLabel.TextAlign='MiddleRight'

    $available=$h-380
    $handGap=[int][Math]::Max(135,[Math]::Min(210,$available/2))
    $dealerY=191
    $playerY=$dealerY+$handGap

    $dealerTotalLabel.SetBounds($pad,$dealerY-27,$tableWidth,27)
    $dealerArea.SetBounds($pad,$dealerY,$tableWidth,110)
    $playerTotalLabel.SetBounds($pad,$playerY-27,$tableWidth,27)
    $playerArea.SetBounds($pad,$playerY,$tableWidth,110)

    $statusY=[int][Math]::Max(($playerY+122),($h-272))
    $statusLabel.SetBounds($pad,$statusY,$tableWidth,40)

    # Betting and action rows remain visible above the footer, including on small screens.
    $chipLabel=$form.Controls | Where-Object { $_ -is [System.Windows.Forms.Label] -and $_.Text -eq 'CLICK CHIPS TO PLACE YOUR BET' } | Select-Object -First 1
    if($chipLabel){$chipLabel.SetBounds(0,($h-225),$w,25)}
    $chipsW=4*66+3*24
    $chipsStart=$mid-[int]($chipsW/2)-48
    for($i=0;$i -lt $chipButtons.Count;$i++){
        $chipButtons[$i].Location=New-Object System.Drawing.Point(($chipsStart+$i*90),($h-193))
    }
    $clearBetButton.SetBounds(($chipsStart+$chipsW+18),($h-185),116,44)
    $actionWidth=116
    $actionGap=16
    $actionsStart=$mid-[int]((3*$actionWidth+2*$actionGap)/2)
    $dealButton.SetBounds($actionsStart,($h-112),$actionWidth,44)
    $hitButton.SetBounds(($actionsStart+$actionWidth+$actionGap),($h-112),$actionWidth,44)
    $standButton.SetBounds(($actionsStart+2*($actionWidth+$actionGap)),($h-112),$actionWidth,44)
    $resetButton.SetBounds(($w-205),($h-51),175,34)

    $footer=$form.Controls | Where-Object { $_ -is [System.Windows.Forms.Label] -and $_.Text -like 'VIRTUAL CHIPS ONLY*' } | Select-Object -First 1
    if($footer){$footer.SetBounds($pad,($h-49),($w-255),30);$footer.TextAlign='MiddleLeft'}
    Center-Hand $dealerArea
    Center-Hand $playerArea
}
# Set a softer appearance and a clear primary action.
$dealButton.BackColor=$red
$dealButton.FlatAppearance.BorderColor=$red
$hitButton.BackColor=[System.Drawing.ColorTranslator]::FromHtml('#743038')
$standButton.BackColor=[System.Drawing.ColorTranslator]::FromHtml('#282830')
$statusLabel.BackColor=$surface
$statusLabel.ForeColor=$white
$dealerArea.Padding=New-Object System.Windows.Forms.Padding(0)
$playerArea.Padding=New-Object System.Windows.Forms.Padding(0)
# Modern presentation: distinct table regions, strong header, and understated control palette.
$brandBar=New-Object System.Windows.Forms.Panel
$brandBar.BackColor=[System.Drawing.ColorTranslator]::FromHtml('#201519')
$brandBar.Dock='Top'
$brandBar.Height=6
$form.Controls.Add($brandBar)
$brandBar.BringToFront()
$form.Controls[0].Font=New-Object System.Drawing.Font('Segoe UI',24,[System.Drawing.FontStyle]::Bold)
$dealerTotalLabel.ForeColor=$red
$playerTotalLabel.ForeColor=$white
$dealerArea.BackColor=[System.Drawing.ColorTranslator]::FromHtml('#171A1D')
$playerArea.BackColor=[System.Drawing.ColorTranslator]::FromHtml('#171A1D')
$dealerArea.BorderStyle='FixedSingle'
$playerArea.BorderStyle='FixedSingle'
$form.Add_Resize({Update-Layout})
$form.Add_Shown({Update-Layout})
Update-Layout
Refresh-Table
[void]$form.ShowDialog()

# BERRY IT Blackjack | Responsive Desktop Edition 3
# Windows PowerShell 5.1 / Windows Forms, virtual chips only.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

function C([string]$hex) { return [System.Drawing.ColorTranslator]::FromHtml($hex) }
$bg=C '#0D0E11'; $surface=C '#17191E'; $surface2=C '#202229'
$line=C '#353840'; $red=C '#FF344D'; $text=C '#F7F7F8'
$muted=C '#A1A4AC'; $green=C '#73D5B3'
$form=New-Object System.Windows.Forms.Form
$form.Text='BERRY IT Blackjack | Desktop Edition 5'
$form.ClientSize=New-Object System.Drawing.Size(980,850)
$form.MinimumSize=New-Object System.Drawing.Size(830,750)
$form.StartPosition='CenterScreen'
$form.BackColor=$bg
$form.ForeColor=$text
$form.Font=New-Object System.Drawing.Font('Segoe UI',10)
$form.AutoScaleMode='Dpi'

function Label([string]$caption,[int]$size,[System.Drawing.Color]$color,[bool]$bold=$false) {
    $l=New-Object System.Windows.Forms.Label
    $l.Text=$caption; $l.ForeColor=$color
    $l.TextAlign='MiddleCenter'; $l.Dock='Fill'
    $l.AutoEllipsis=$true
    $style=[System.Drawing.FontStyle]::Regular
    if($bold){$style=[System.Drawing.FontStyle]::Bold}
    $l.Font=New-Object System.Drawing.Font('Segoe UI',$size,$style)
    return $l
}
function TableRow([System.Windows.Forms.TableLayoutPanel]$table,[int]$index,[System.Windows.Forms.Control]$control){
    $table.Controls.Add($control,0,$index)
}
function Action([string]$caption,[System.Drawing.Color]$color) {
    $b=New-Object System.Windows.Forms.Button
    $b.Text=$caption; $b.Dock='Fill'
    $b.BackColor=$color; $b.ForeColor=$text
    $b.FlatStyle='Flat'; $b.FlatAppearance.BorderSize=0
    $b.Cursor='Hand'; $b.Margin=New-Object System.Windows.Forms.Padding(6,5,6,5)
    $b.Font=New-Object System.Drawing.Font('Segoe UI',11,[System.Drawing.FontStyle]::Bold)
    return $b
}
function Grid([int]$rows) {
    $t=New-Object System.Windows.Forms.TableLayoutPanel
    $t.Dock='Fill';$t.ColumnCount=1;$t.RowCount=$rows
    $t.Padding=New-Object System.Windows.Forms.Padding(0)
    $t.Margin=New-Object System.Windows.Forms.Padding(0)
    return $t
}

# Header never overlaps the play area.
$header=New-Object System.Windows.Forms.Panel
$header.Dock='Top';$header.Height=112;$header.BackColor=$surface

$brand=Label 'B E R R Y   I T' 19 $red $true
$brand.Dock='Top';$brand.Height=47;$header.Controls.Add($brand)
$heading=Label 'B L A C K J A C K' 12 $text $true
$heading.Dock='Top';$heading.Height=31;$header.Controls.Add($heading)
$header.Controls.SetChildIndex($heading,0)
$sub=Label 'DESKTOP EDITION 5     •     VIRTUAL CHIPS ONLY' 9 $muted
$sub.Dock='Bottom';$sub.Height=26;$header.Controls.Add($sub)
$accent=New-Object System.Windows.Forms.Panel
$accent.Dock='Bottom';$accent.Height=3;$accent.BackColor=$red;$header.Controls.Add($accent)

# Bottom control area occupies its own space, even at minimum size.
$controls=New-Object System.Windows.Forms.Panel
$controls.Dock='Bottom';$controls.Height=174;$controls.BackColor=$surface

$controlGrid=Grid 4
$controlGrid.Padding=New-Object System.Windows.Forms.Padding(18,7,18,9)
$controlGrid.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute',22))) | Out-Null
$controlGrid.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute',59))) | Out-Null
$controlGrid.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute',50))) | Out-Null
$controlGrid.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent',100))) | Out-Null
$controls.Controls.Add($controlGrid)
$null=TableRow $controlGrid 0 (Label 'SELECT CHIPS TO PLACE YOUR BET' 10 $muted $true)
$chips=New-Object System.Windows.Forms.FlowLayoutPanel
$chips.Dock='Fill';$chips.WrapContents=$false;$chips.AutoScroll=$false
$chips.FlowDirection='LeftToRight'
$chips.BackColor=$surface
$chips.Anchor='None'
$chips.Width=390
$chips.Height=57
$null=TableRow $controlGrid 1 $chips
$actions=New-Object System.Windows.Forms.TableLayoutPanel
$actions.Dock='Fill';$actions.RowCount=1;$actions.ColumnCount=3
$actions.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent',33.333))) | Out-Null
$actions.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent',33.333))) | Out-Null
$actions.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent',33.334))) | Out-Null
$actions.MaximumSize=New-Object System.Drawing.Size(450,0)
$actions.Anchor='None';$actions.Width=450;$actions.Height=48
$null=TableRow $controlGrid 2 $actions
$dealButton=Action 'DEAL' $red
$hitButton=Action 'HIT' (C '#73313B')
$standButton=Action 'STAND' $surface2
$actions.Controls.Add($dealButton,0,0)
$actions.Controls.Add($hitButton,1,0)
$actions.Controls.Add($standButton,2,0)

$footer=New-Object System.Windows.Forms.TableLayoutPanel
$footer.Dock='Fill';$footer.RowCount=1;$footer.ColumnCount=2
$footer.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent',66))) | Out-Null
$footer.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent',34))) | Out-Null
$footerText=Label 'BLACKJACK PAYS 3:2  •  DEALER STANDS ON 17' 9 $muted
$footerText.TextAlign='MiddleLeft'
$resetButton=Action 'RESET BANKROLL' $surface2
$resetButton.Font=New-Object System.Drawing.Font('Segoe UI',9,[System.Drawing.FontStyle]::Bold)
$footer.Controls.Add($footerText,0,0);$footer.Controls.Add($resetButton,1,0)
$null=TableRow $controlGrid 3 $footer

# Table and hands use proportional space, not absolute y coordinates.
$main=New-Object System.Windows.Forms.Panel
$main.Dock='Fill';$main.Padding=New-Object System.Windows.Forms.Padding(30,8,30,8)

$play=Grid 7
$play.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute',39))) | Out-Null
$play.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute',29))) | Out-Null
$play.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent',50))) | Out-Null
$play.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute',12))) | Out-Null
$play.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute',29))) | Out-Null
$play.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent',50))) | Out-Null
$play.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute',42))) | Out-Null
$main.Controls.Add($play)
# Dedicated root grid: header, flexible table, bottom controls each own a row.
# Never use competing Dock.Top/Bottom/Fill siblings on the Form.
$root=New-Object System.Windows.Forms.TableLayoutPanel
$root.Dock='Fill';$root.ColumnCount=1;$root.RowCount=3
$root.Margin=New-Object System.Windows.Forms.Padding(0)
$root.Padding=New-Object System.Windows.Forms.Padding(0)
$root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute',112))) | Out-Null
$root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent',100))) | Out-Null
$root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute',174))) | Out-Null
$form.Controls.Add($root)
$header.Dock='Fill';$main.Dock='Fill';$controls.Dock='Fill'
$root.Controls.Add($header,0,0)
$root.Controls.Add($main,0,1)
$root.Controls.Add($controls,0,2)

$stats=New-Object System.Windows.Forms.TableLayoutPanel
$stats.Dock='Fill';$stats.ColumnCount=2;$stats.RowCount=1
$stats.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent',50))) | Out-Null
$stats.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent',50))) | Out-Null
$balanceLabel=Label 'BALANCE: 100 CHIPS' 14 $text $true
$balanceLabel.TextAlign='MiddleLeft'
$betLabel=Label 'BET: 0 CHIPS' 14 $red $true
$betLabel.TextAlign='MiddleRight'
$stats.Controls.Add($balanceLabel,0,0);$stats.Controls.Add($betLabel,1,0)
$null=TableRow $play 0 $stats
$dealerTotalLabel=Label 'DEALER  |  TOTAL: --' 11 $red $true
$playerTotalLabel=Label 'YOUR HAND  |  TOTAL: --' 11 $text $true
$null=TableRow $play 1 $dealerTotalLabel
$null=TableRow $play 4 $playerTotalLabel

function HandPanel {
    $p=New-Object System.Windows.Forms.Panel
    $p.Dock='Fill';$p.BackColor=$surface;$p.Margin=New-Object System.Windows.Forms.Padding(0,2,0,2)
    $p.BorderStyle='FixedSingle'
    return $p
}
$dealerArea=HandPanel;$playerArea=HandPanel
$null=TableRow $play 2 $dealerArea
$null=TableRow $play 5 $playerArea
$statusLabel=Label 'Select chips below to place your bet.' 12 $text $true
$statusLabel.BackColor=$surface2
$statusLabel.Margin=New-Object System.Windows.Forms.Padding(0,8,0,0)
$null=TableRow $play 6 $statusLabel

$state=@{Balance=100;Bet=0;SelectedBet=0;Deck=@();Player=@();Dealer=@();InRound=$false}
$chipButtons=@()
$chipSpecs=@(
    @{Value=5;Color='#596474'},
    @{Value=10;Color='#147F92'},
    @{Value=25;Color='#C17B20'},
    @{Value=50;Color='#C72348'}
)
foreach($spec in $chipSpecs) {
    $chip=New-Object System.Windows.Forms.Button
    $chip.Text=[string]$spec.Value
    $chip.Tag=[int]$spec.Value
    $chip.Size=New-Object System.Drawing.Size(50,50)
    $chip.Margin=New-Object System.Windows.Forms.Padding(5,2,5,2)
    $chip.FlatStyle='Flat';$chip.FlatAppearance.BorderSize=0
    $chip.Cursor='Hand';$chip.BackColor=$surface
    $chip.ForeColor=$text
    $chip.Font=New-Object System.Drawing.Font('Segoe UI',10,[System.Drawing.FontStyle]::Bold)
    $chipColors=@{5=(C '#596474');10=(C '#147F92');25=(C '#C17B20');50=(C '#C72348')}
    $chip.Add_Paint({
        param($sender,$e)
        $e.Graphics.SmoothingMode=[System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $e.Graphics.TextRenderingHint=[System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
        $e.Graphics.Clear($surface)
        $v=[int]$sender.Tag
        $fill=New-Object System.Drawing.SolidBrush($chipColors[$v])
        $ring=New-Object System.Drawing.Pen($text,3)
        $inner=New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(170,255,255,255),1)
        try {
            $e.Graphics.FillEllipse($fill,3,3,44,44)
            $e.Graphics.DrawEllipse($ring,3,3,44,44)
            $e.Graphics.DrawEllipse($inner,8,8,34,34)
            [System.Windows.Forms.TextRenderer]::DrawText($e.Graphics,$sender.Text,$sender.Font,(New-Object System.Drawing.Rectangle(3,3,45,45)),$text,([System.Windows.Forms.TextFormatFlags]::HorizontalCenter -bor [System.Windows.Forms.TextFormatFlags]::VerticalCenter -bor [System.Windows.Forms.TextFormatFlags]::SingleLine))
        } finally {$fill.Dispose();$ring.Dispose();$inner.Dispose()}
    })
    $chip.Add_Click({
        if($state.InRound){return}
        $amount=[int]$this.Tag
        if($state.SelectedBet+$amount -le $state.Balance){
            $state.SelectedBet+=$amount
            $statusLabel.Text="Bet selected: $($state.SelectedBet) chips. Press DEAL."
            $statusLabel.ForeColor=$text
        } else {
            $statusLabel.Text='Insufficient balance for that chip.'
            $statusLabel.ForeColor=$red
        }
        Refresh-Table
    })
    $chips.Controls.Add($chip)
    $chipButtons+= $chip
}
$clearBetButton=New-Object System.Windows.Forms.Button
$clearBetButton.Text='CLEAR BET';$clearBetButton.Size=New-Object System.Drawing.Size(112,37)
$clearBetButton.Margin=New-Object System.Windows.Forms.Padding(10,7,0,0)
$clearBetButton.BackColor=$surface2;$clearBetButton.ForeColor=$text
$clearBetButton.FlatStyle='Flat';$clearBetButton.FlatAppearance.BorderSize=1
$clearBetButton.FlatAppearance.BorderColor=$line
$clearBetButton.Font=New-Object System.Drawing.Font('Segoe UI',9,[System.Drawing.FontStyle]::Bold)
$clearBetButton.Cursor='Hand'
$chips.Controls.Add($clearBetButton)
$clearBetButton.Add_Click({
    if($state.InRound){return}
    $state.SelectedBet=0;$statusLabel.Text='Select chips below to place your bet.'
    $statusLabel.ForeColor=$text;Refresh-Table
})

function Get-Score($hand) {
    $score=0;$aces=0
    foreach($card in $hand){
        $rank=$card.Split(':')[0]
        if($rank -eq 'A'){$score+=11;$aces++}
        elseif($rank -in @('J','Q','K')){$score+=10}
        else{$score+=[int]$rank}
    }
    while($score -gt 21 -and $aces -gt 0){$score-=10;$aces--}
    return $score
}
function Draw-Card {
    $last=$state.Deck.Count-1
    $card=$state.Deck[$last]
    if($last -eq 0){$state.Deck=@()}else{$state.Deck=@($state.Deck[0..($last-1)])}
    return $card
}
function Center-Hand($area) {
    $cards=@($area.Controls)
    $n=$cards.Count
    if($n -eq 0){return}
    $cardWidth=70;$gap=10
    $full=$n*$cardWidth+($n-1)*$gap
    $left=[Math]::Max(8,[int](($area.ClientSize.Width-$full)/2))
    $top=[Math]::Max(4,[int](($area.ClientSize.Height-98)/2))
    for($i=0;$i -lt $n;$i++){
        $cards[$i].SetBounds(($left+$i*($cardWidth+$gap)),$top,$cardWidth,98)
    }
}
function Draw-Hand($area,$hand,$hideHole) {
    $area.SuspendLayout()
    $area.Controls.Clear()
    for($i=0;$i -lt $hand.Count;$i++){
        $card=New-Object System.Windows.Forms.Label
        $card.BackColor=(C '#FCFCFC')
        $card.ForeColor=(C '#14151A')
        $card.BorderStyle='FixedSingle'
        $card.TextAlign='MiddleCenter'
        $card.Font=New-Object System.Drawing.Font('Segoe UI',20,[System.Drawing.FontStyle]::Bold)
        if($hideHole -and $i -eq 1){
            $card.BackColor=$red;$card.ForeColor=$text;$card.Text='✦'
        } else {
            $parts=$hand[$i].Split(':')
            $card.Text=$parts[0]+"`r`n"+$parts[1]
            if($parts[1] -in @('♥','♦')){$card.ForeColor=$red}
        }
        $area.Controls.Add($card)
    }
    $area.ResumeLayout()
    Center-Hand $area
}
function Refresh-Table {
    $balanceLabel.Text="BALANCE: $($state.Balance) CHIPS"
    $shown=if($state.InRound){$state.Bet}else{$state.SelectedBet}
    $betLabel.Text="BET: $shown CHIPS"
    Draw-Hand $dealerArea $state.Dealer $state.InRound
    Draw-Hand $playerArea $state.Player $false
    if($state.Player.Count){$playerTotalLabel.Text="YOUR HAND  |  TOTAL: $(Get-Score $state.Player)"}
    else{$playerTotalLabel.Text='YOUR HAND  |  TOTAL: --'}
    if(-not $state.Dealer.Count){$dealerTotalLabel.Text='DEALER  |  TOTAL: --'}
    elseif($state.InRound){$dealerTotalLabel.Text="DEALER  |  SHOWING: $(Get-Score @($state.Dealer[0])) (+ hidden card)"}
    else{$dealerTotalLabel.Text="DEALER  |  TOTAL: $(Get-Score $state.Dealer)"}
    $dealButton.Enabled=(-not $state.InRound -and $state.SelectedBet -ge 5 -and $state.SelectedBet -le $state.Balance)
    $hitButton.Enabled=$state.InRound;$standButton.Enabled=$state.InRound
    foreach($chip in $chipButtons){$chip.Enabled=(-not $state.InRound)}
    $clearBetButton.Enabled=(-not $state.InRound)
    if($state.Balance -lt 5 -and -not $state.InRound){
        $dealButton.Enabled=$false
        $statusLabel.Text='Out of chips. RESET BANKROLL to play again.'
    }
}
function End-Round($result) {
    $state.InRound=$false
    $ps=Get-Score $state.Player;$ds=Get-Score $state.Dealer
    if($result -eq 'win'){
        $state.Balance+=$state.Bet
        $statusLabel.Text="YOU WIN! +$($state.Bet) chips  |  $ps vs $ds"
        $statusLabel.ForeColor=$green
    } elseif($result -eq 'blackjack'){
        $gain=[int][Math]::Round($state.Bet*1.5,0,[MidpointRounding]::AwayFromZero)
        $state.Balance+=$gain
        $statusLabel.Text="BLACKJACK! +$gain chips"
        $statusLabel.ForeColor=$green
    } elseif($result -eq 'lose'){
        $state.Balance-=$state.Bet
        $statusLabel.Text="DEALER WINS -$($state.Bet) chips  |  $ps vs $ds"
        $statusLabel.ForeColor=$red
    } else {
        $statusLabel.Text="PUSH — no chips won or lost  |  $ps vs $ds"
        $statusLabel.ForeColor=$text
    }
    $state.SelectedBet=0
    Refresh-Table
}
$dealButton.Add_Click({
    $bet=[int]$state.SelectedBet
    if($bet -lt 5 -or $bet -gt $state.Balance -or $bet%5 -ne 0){return}
    $ranks=@('A','2','3','4','5','6','7','8','9','10','J','Q','K')
    $suits=@('♠','♥','♣','♦')
    $deck=@(foreach($suit in $suits){foreach($rank in $ranks){"${rank}:${suit}"}})
    $state.Deck=@($deck | Get-Random -Count 52)
    $state.Player=@((Draw-Card),(Draw-Card))
    $state.Dealer=@((Draw-Card),(Draw-Card))
    $state.Bet=$bet;$state.InRound=$true
    $statusLabel.Text='Your turn — HIT or STAND';$statusLabel.ForeColor=$text
    $ps=Get-Score $state.Player;$ds=Get-Score $state.Dealer
    if($ps -eq 21 -and $ds -eq 21){End-Round 'push'}
    elseif($ps -eq 21){End-Round 'blackjack'}
    elseif($ds -eq 21){End-Round 'lose'}
    else{Refresh-Table}
})
$hitButton.Add_Click({
    $state.Player=@($state.Player)+@(Draw-Card)
    if((Get-Score $state.Player) -gt 21){End-Round 'lose'}
    else{Refresh-Table}
})
$standButton.Add_Click({
    while((Get-Score $state.Dealer) -lt 17){
        $state.Dealer=@($state.Dealer)+@(Draw-Card)
    }
    $p=Get-Score $state.Player;$d=Get-Score $state.Dealer
    if($d -gt 21 -or $p -gt $d){End-Round 'win'}
    elseif($p -eq $d){End-Round 'push'}
    else{End-Round 'lose'}
})
$resetButton.Add_Click({
    $response=[System.Windows.Forms.MessageBox]::Show('Reset virtual bankroll to 100 chips?','Reset bankroll','YesNo','Question')
    if($response -ne 'Yes'){return}
    $state.Balance=100;$state.Bet=0;$state.SelectedBet=0;$state.InRound=$false
    $state.Player=@();$state.Dealer=@()
    $statusLabel.Text='Select chips below to place your bet.'
    $statusLabel.ForeColor=$text
    Refresh-Table
})
$dealerArea.Add_Resize({Center-Hand $dealerArea})
$playerArea.Add_Resize({Center-Hand $playerArea})
Refresh-Table
[void]$form.ShowDialog()

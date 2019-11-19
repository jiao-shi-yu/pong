# pong


## 这是我第二次尝试完成CS50的游戏开发课程，下载了love2D v1.10.2，希望能完成吧。Good luck！

## v10 笔记
添加了胜利状态

1. 游戏进行中，进球的一方的分数达到10分，游戏状态就会从play变成done,记录胜利玩家winningPlayer;达不到10分则被进球方serve，重置球的位置到屏幕中央。

2. 游戏结束后，设置UI：Player 1 or 2 wins. Press enter to restart。

3. 游戏结束后，用户按下回车，游戏就会从结束状态进入发球状态。（相当于省去了开始状态，这样用户可以少按一次键盘）这时候一轮游戏已经结束，新的一轮游戏就要开始，所以分数要归零。上一轮游戏的输家，发球。
`servingPlayer = winningPlayer == 1 and 2 or 1`

！！！自己遇到的BUG就是，分数会一致上涨，不会显示到胜利页面。

找到了！！ 要在play状态下，检测进球与否。我把检测的代码，写在了play if语句之外了。

如此说来，前面的几个版本也写错了。哈哈哈哈哈哈

回来接着思考，检测进球与否以及加分的代码，写在play if语句之外：
这样一来，即便不是play状态（done啊，start等等），也会加分。
应该是，在play状态下，超出边界才会加分。

然后，done状态下，超出边界也不加分。有两个bug。先改一个bug测试一下。

测试完成后……

的确现在不会得到11分这样的分数。

但是：
done状态下，按 enter 之后
会看不到球。。。。。

哦发现了。
gameState = 'serve'
我写成了
gameState = serve
没加引号。。。

4. 为了避免出现ball.dx = 0.1, ball.dy = 100这种情况（球上下弹起来没完，最要命的是，水平方向的速度贼慢，进个球的时间特长），
所以为了测试方便，也是为了游戏体验。
把Ball:reset()里面，随机生成dx, dy的代码改写一下。
从：
```
self.dx = math.random(-50, 50)
```
改为：
```
self.dx = math.random(2) == 1 and math.random(-80, -100) or math.random(80, 100)
```
主要是改dx， dy的问题不大。

现在是2019年11月19日，君青突然，在我心中不重要了。觉得善良的人是离墨嫣和小郭。哈哈，时间果然是良药，真甜。就像陈茜一样，没了很深的印象。原来天涯和处无芳草。钱名利，不重要。快乐竟然是发现并解决一个BUG。

然后这时候发现：
ball:reset()中, dy = -100 or 100, dx = 80~100, 
serve中, dy =  -50～50， dx = math.random(140, 200).
可以明显看出： 1.serve的时候，dx更快。2.reset()更垂直，serve更水平。
33333.！！！哦明白了。虽然serve的时候，很直，但是呢，碰到杆之后，就会调用reset()方法。reset中的角度（更偏上下）就比较合理了，一定会碰到上下边框。

5.然后现在的问题： 胜利界面UI，字体重合，我觉的好像是把那个数字增大就可以了。就可以往下挪了。试试看吧。

OK，第二个数字参数，就是文本框的Y坐标！


6.现在的问题：
玩家一赢了，玩家二发球，按下回车键，玩家一直接得一分。emm...
是这样哈，进入done，按下回车键之后， game = 'serve', 分数都归零， servingPlayer = 2.
现在gameState不是等于'serve'了嘛，所以就会运行update(dt)中的serve if语句，
```
if gameState == 'serve' then
		-- before switching to play, initialize ball's velocity based on player who last scored
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = - math.random(140, 200)
		end
```
得到一个 dx, dy 没什么大不了的。
然后就呆在serve状态下，直到你再按一下回车。
按下回车后，
```
elseif gameState == 'serve' then
			gameState = 'play'
```
serve 变play了，紧接在play中会判断
```
		if ball.x < 0 then
			servingPlayer = 1
			player2Score = player2Score + 1
			if player2Score == 10 then
				gameState = 'done'
				winningPlayer = 2
			else
				ball:reset()
				gameState = 'serve'
			end
		end

		if ball.x > VIRTUAL_WIDTH then
			servingPlayer = 2
			player1Score = player1Score + 1
			if player1Score == 10 then
				gameState = 'done'
				winningPlayer = 1
			else
				ball:reset()
				gameState = 'serve'
			end
		end
```
而在上一轮游戏当中，玩家二输了，球还在玩家二的右边，没有重置到屏幕中央。这样一来。ball.x > VIRTUAL_WIDTH 成立， player1Score = player1Score + 1， 玩家一直接得一分。

所以要解决这个问题，就是在一轮游戏结束后， 也就是done状态下。把球放回到屏幕中央。
也是就是ball:reset()当中有x, y 重置。

然后我有一个突发奇想，就是serve的时候把球发在屏幕的任意位置只要不超过上下左右边框，也就是
```
y = math.random(0, VIRTUAL_HEIGHT - 4)
x = math.random(player1.x + 5, player2.x) --可以缩小，这个是极限范围
```

行，在此版本中先不写这个图发奇想了。先测试他给的版本。还有一个idea就是球可以持续变色。
好，开始测试吧。

干啥来着，哦。done状态下
好啦测试完成，下一个版本就是加入声音啦。

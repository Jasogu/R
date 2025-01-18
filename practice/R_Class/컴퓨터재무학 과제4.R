#컴퓨터 재무학 과제4, 154p
#Chapter 4
#Problems 1, 3, 6
#In problem 6 (iv), "If the variance of price changes with assess, lotsize, sqrft, or bdrms" means that "If heteroskedasticity in error terms eixts".
#Computer Exercises C1, C6

#problems 1
#(i) t값의 분모인 s.e에 영향을 주므로 t분포에 영향이 생김
#(ii) 변수들간에 다중공선성 문제가 있을 경우, 정확도가 떨어질 뿐이지 t분포를 무력화 시키지않음
#(iii) 중요한 변수가 빠져있을 경우 bias가 생겨 t분포에 영향이 생김
#답. 1번과 3번

#problems 3
#(i) 0.321*0.1 이므로 0.0321 = 3.21%pt 가 상승한다.
#(ii) H0 : b1 = 0, H1 : b1 != 0, qt(0.95, 29)=1.699, qt(0.9, 29)=1.311, t = 0.321/0.216=1.486 이므로 신뢰구간 10%에서 H0 기각, 5%에서 H0 채택
#(iii) delta profmarg=1%pt 증가, delta raintens=10*0.050 = 5%pt 증가. 경제적으로 효율적으로 보임
#(iv) t값=0.05/0.46=1.086 으로 통계적으로 유의미하지 않다

#problems 6, data = HPRICE1
#(i) H0 : b1=1 이므로 t=(0.976-1)/0.049=-0.489 이므로 H0 채택
#(ii) restricted model : price = assess + u, u = price-assess, SSR = sigma(price-assess)^2 = 209,448
#SSR_r = 209,448.99, SSR_ur = 165,644.51, q=2개(b0:0, b1:1), F = [(R_ur^2 - R_r^2)/q]/[(1-R_ur^2)/n-k-1], answer = 86
attach(data)
u_hat2 <- (price - assess)^2 
sum(u_hat2)
lm(price ~ assess-1) %>% summary
lm(price ~ assess) %>% summary
#(iii) 
#(iv) 

#C1, 4ch ppt참고
#(i) A후보가 비용을 1% 올렸을 때 A후보의 투표량의 변화
#(ii) H0 : b2 = -b1, S=b1+b2=0, H0 : S=0, H1 : S != 0, b1 = S - b2
#y = b0 + S*log(X1) + b2*(log(X2)-log(X1)) + b3*X3 + u

#(iv)lm(y ~ x1 + x2 + x3), lm(y ~ x1 + I(x2-x1) + x3)에서 x1의 계수 t-test. t = (b1+b2)/se(b1+b2)

#C6
#(i) H0 : b2=b3, b2-b3=0=S

#(ii)confint(lm, level=0.95)



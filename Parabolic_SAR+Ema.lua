Settings = 
{
        Name = "*Parabolic_SAR+Ema",
        period = 21,
        period2 = 256,
        deviation=2,
        line=
        {
                {
                        Name = "Sar",
                        Color = RGB(0, 64, 0),
                        Type = TYPET_BAR,
                        Width = 3
                },
                {
                        Name = "EMA",
                        Color = RGB(0, 128, 0),
                        Type = TYPE_LINE,
                        Width = 2
                }
        ,
                {
                        Name = "BBB",
                        Color = RGB(0, 0, 255),
                        Type = TYPE_TRIANGLE_UP,
                        Width = 1
                }
        ,
                {
                        Name = "SSS",
                        Color = RGB(255, 0, 0),
                        Type = TYPE_TRIANGLE_DOWN,
                        Width = 1
                }
        }
}

----------------------------------------------------------
function cached_SAR()
        local cache_SAR={}
        local cache_ST={}
        local EMA={}
        local BB={}
        
        return function(ind, _p, _p2,_ddd)
                local period = _p
                local index = ind
                local sigma = 0

                if index == 1 then
                        cache_SAR={}
                        cache_ST={}
                        EMA={}
                        BB={}
                        
                        BB[index]=0
                        cache_SAR[index]=L(index)-2*(H(index)-L(index))
                        EMA[index]=(C(index)+O(index))/2
                        cache_ST[index]=1
                        return nil
                end
                ------------------------------
                        EMA[index]=(2/(_p/2+1))*C(index)+(1-2/(_p/2+1))*EMA[index-1]
                        BB[index]=(2/(_p2/2+1))*(C(index)-EMA[index])^2+(1-2/(_p2/2+1))*BB[index-1]
                        cache_SAR[index]=cache_SAR[index-1]
                        cache_ST[index]=cache_ST[index-1]

                        sigma=BB[index]^(1/2)

                if index ==2 then
                        return nil
                end
------------------------------------------------------------------              
                if cache_ST[index]==1 then
                                
                        cache_SAR[index]=math.max((EMA[index]-sigma*_ddd),cache_SAR[index-1])
                                                
                        if (cache_SAR[index] > C(index)) then 
                                cache_ST[index]=0
                                cache_SAR[index]=EMA[index]+sigma*_ddd
                                return  cache_SAR[index], EMA[index], nil,C(index)
                        end
                end
----------------------------

                if cache_ST[index]==0 then
                                
                        cache_SAR[index]=math.min((EMA[index]+sigma*_ddd),cache_SAR[index-1])
                
                        if (cache_SAR[index] < C(index)) then 
                                cache_ST[index]=1
                                cache_SAR[index]=EMA[index]-sigma*_ddd*1
                                return cache_SAR[index], EMA[index], C(index),nil
                        end
                end
                
----------------------------------
                                                                
                return cache_SAR[index], EMA[index], nil, nil
                        
        end
end
----------------------------

function Init()
        mySAR = cached_SAR()
        return 4
end

function OnCalculate(index)
        return mySAR(index, Settings.period, Settings.period2,Settings.deviation)
end

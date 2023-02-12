Settings =
{	
	Name = "DHLM",
		line = 
{
	{
	Name = "High",
		Color = RGB(0,200,64),
		Type = TYPET_BAR,
		Width = 1
	},
{
	Name = "Low",
		Color = RGB(200,0,64),
		Type = TYPET_BAR,
		Width = 1
	},
{
	Name = "Median",
		Color = RGB(0,64,200),
		Type = TYPET_BAR,
		Width = 1
		}
	}
}
	
local hlm = {}
local math_max = math.max
local math_min = math.min

function Init()
    return #Settings.line
end
function OnCalculate(index)
local dt = T(index)

	if O(index) then
	if dt.day ~= hlm.day or 
		dt.month ~= hlm.month or 
		dt.year ~= hlm.year then
		hlm.year = dt.year
		hlm.day = dt.day
		hlm.month = dt.month
		hlm.high = H(index)
		hlm.low = L(index)
	 else
		hlm.high = math_max(hlm.high,H(index))
		hlm.low = math_min(hlm.low,L(index))
		hlm.median = (hlm.high + hlm.low)/2
		end
	end
	return hlm.high,hlm.low,hlm.median
end

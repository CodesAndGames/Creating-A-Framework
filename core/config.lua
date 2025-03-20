return {
	enableHud = true,

	['defaultData'] = {
		['age'] = 21,
		['bank'] = {
			['cash'] = 500,
			['checking'] = {
				['account'] = math.random(1000,9999)..'-'..math.random(1000,9999),
				['balance'] = 100,
			},
			['savings'] = {
				['account'] = math.random(1000,9999)..'-'..math.random(1000,9999),
				['balance'] = 50,
			},
		}
	},
}
SELECT 

user_id,
u.surname,
sum(fcost) as sum,
sum(IF(holiday=1, fcost, 0)) as holidaySum,
sum(IF(afterwork=1 AND holiday=0, fcost, 0)) as afterworkSum,
sum(IF(afterwork=0 AND holiday=0, fcost, 0)) as workSum,

sum(fcost*(percent/100)) as salarySum,
sum(IF(holiday=1, fcost*(holiday_percent/100), 0)) as holidaySalarySum,
sum(IF(afterwork=1 AND holiday=0, fcost*(afterwork_percent/100), 0)) as afterworkSalarySum,
sum(IF(afterwork=0 AND holiday=0, fcost*(work_percent/100), 0)) as workSalarySum


FROM 

(
	SELECT 
		sok.user_id, 
		sok.date, 
		COALESCE(p.afterwork, 0) as afterwork,
		COALESCE(partial_cost, fixed_cost) as fcost,
		IF(h.date, 1, 0) as holiday,

		IF(sus.id, sus.work_percent,
			IF(susg.id, susg.work_percent,
				IF(ss.id, ss.work_percent,
					IF(ssg.id, ssg.work_percent,
						IF(su.id, su.work_percent,
							IF(sb.id, sb.work_percent, 0)
						)
					)
				)
			)
		) as work_percent,

		IF(sus.id, sus.afterwork_percent,
			IF(susg.id, susg.afterwork_percent,
				IF(ss.id, ss.afterwork_percent,
					IF(ssg.id, ssg.afterwork_percent,
						IF(su.id, su.afterwork_percent,
							IF(sb.id, sb.afterwork_percent, 0)
						)
					)
				)
			)
		) as afterwork_percent,

		IF(sus.id, sus.holiday_percent,
			IF(susg.id, susg.holiday_percent,
				IF(ss.id, ss.holiday_percent,
					IF(ssg.id, ssg.holiday_percent,
						IF(su.id, su.holiday_percent,
							IF(sb.id, sb.holiday_percent, 0)
						)
					)
				)
			)
		) as holiday_percent,

		IF(sus.id, IF(h.date, sus.holiday_percent, IF(p.afterwork, sus.afterwork_percent, sus.work_percent)),
			IF(susg.id, IF(h.date, susg.holiday_percent, IF(p.afterwork, susg.afterwork_percent, susg.work_percent)),
				IF(ss.id, IF(h.date, ss.holiday_percent, IF(p.afterwork, ss.afterwork_percent, ss.work_percent)),
					IF(ssg.id, IF(h.date, ssg.holiday_percent, IF(p.afterwork, ssg.afterwork_percent, ssg.work_percent)),
						IF(su.id, IF(h.date, su.holiday_percent, IF(p.afterwork, su.afterwork_percent, su.work_percent)),
							IF(sb.id, IF(h.date, sb.holiday_percent, IF(p.afterwork, sb.afterwork_percent, sb.work_percent)), 0)
						)
					)
				)
			)
		) as percent

	FROM service_ok sok 
	LEFT JOIN visit v ON sok.visit_id = v.id
	LEFT JOIN priem p ON v.priem_id = p.id
	LEFT JOIN holiday h ON h.date = p.work_date
	LEFT JOIN service s ON sok.service_id = s.id

	LEFT JOIN salary_filter sus ON sok.user_id = sus.user_id AND sok.service_id = sus.service_id AND sus.deleted=0
	LEFT JOIN salary_filter susg ON sok.user_id = susg.user_id AND s.group_id = susg.service_group_id AND susg.deleted=0
	LEFT JOIN salary_filter ss ON sok.service_id = ss.service_id AND ss.user_id IS NULL AND ss.deleted=0
	LEFT JOIN salary_filter ssg ON s.group_id = ssg.service_group_id AND ssg.user_id IS NULL AND ssg.deleted=0
	LEFT JOIN salary_filter su ON sok.user_id = su.user_id AND su.service_id IS NULL AND su.service_group_id IS NULL AND su.deleted=0
	LEFT JOIN salary_filter sb ON sb.user_id IS NULL AND sb.service_id IS NULL AND sb.service_group_id IS NULL AND sb.deleted=0

	WHERE sok.deleted=0 AND sok.date >= "2015-10-01" AND sok.date <= "2015-10-30"
) t

LEFT JOIN user u ON user_id = u.id

GROUP BY user_id
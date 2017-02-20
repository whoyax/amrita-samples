SELECT 

user_id,
u.surname,

sum(IF(holiday=1, 1, 0)) as holidayCnt,
sum(IF(afterwork=1 AND holiday=0, 1, 0)) as afterworkCnt,
sum(IF(afterwork=0 AND holiday=0, 1, 0)) as workCnt,

		SUM(t.clientCnt) as clientCnt,
		
		SUM(COALESCE(sus_holidayPaymentCnt, 0) 
			+ COALESCE(susg_holidayPaymentCnt, 0)
			+ COALESCE(ss_holidayPaymentCnt, 0)
			+ COALESCE(ssg_holidayPaymentCnt, 0)
			+ COALESCE(su_holidayPaymentCnt, 0)
			+ COALESCE(sb_holidayPaymentCnt, 0)
		) as holidayPaymentCnt,
		
		SUM(COALESCE(sus_afterworkPaymentCnt, 0) 
			+ COALESCE(susg_afterworkPaymentCnt, 0)
			+ COALESCE(ss_afterworkPaymentCnt, 0)
			+ COALESCE(ssg_afterworkPaymentCnt, 0)
			+ COALESCE(su_afterworkPaymentCnt, 0)
			+ COALESCE(sb_afterworkPaymentCnt, 0)
		) as afterworkPaymentCnt,
		
		SUM(COALESCE(sus_workPaymentCnt, 0)
			+ COALESCE(susg_workPaymentCnt, 0)
			+ COALESCE(ss_workPaymentCnt, 0)
			+ COALESCE(ssg_workPaymentCnt, 0)
			+ COALESCE(su_workPaymentCnt, 0)
			+ COALESCE(sb_workPaymentCnt, 0)
		) as workPaymentCnt,

		SUM(COALESCE(sus_paymentCnt, 0)
			+ COALESCE(susg_paymentCnt, 0)
			+ COALESCE(ss_paymentCnt, 0)
			+ COALESCE(ssg_paymentCnt, 0)
			+ COALESCE(su_paymentCnt, 0)
			+ COALESCE(sb_paymentCnt, 0)
		) as paymentCnt,

		SUM(COALESCE(sus_holidayPaymentSum, 0)
			+ COALESCE(susg_holidayPaymentSum, 0)
			+ COALESCE(ss_holidayPaymentSum, 0)
			+ COALESCE(ssg_holidayPaymentSum, 0)
			+ COALESCE(su_holidayPaymentSum, 0)
			+ COALESCE(sb_holidayPaymentSum, 0)
		) as holidayPaymentSum,

		SUM(COALESCE(sus_afterworkPaymentSum, 0)
			+ COALESCE(susg_afterworkPaymentSum, 0)
			+ COALESCE(ss_afterworkPaymentSum, 0)
			+ COALESCE(ssg_afterworkPaymentSum, 0)
			+ COALESCE(sb_afterworkPaymentSum, 0)
		) as afterworkPaymentSum,

		SUM(COALESCE(sus_workPaymentSum, 0)
			+ COALESCE(susg_workPaymentSum, 0)
			+ COALESCE(ss_workPaymentSum, 0)
			+ COALESCE(ssg_workPaymentSum, 0)
			+ COALESCE(sb_workPaymentSum, 0)
		) as workPaymentSum,

		SUM(COALESCE(sus_paymentSum, 0)
			+ COALESCE(susg_paymentSum, 0)
			+ COALESCE(ss_paymentSum, 0)
			+ COALESCE(ssg_paymentSum, 0)
			+ COALESCE(sb_paymentSum, 0)
		) as paymentSum

FROM 

(
	SELECT 
		sok.user_id, 
		sok.date, 
		COALESCE(p.afterwork, 0) as afterwork,
		IF(h.date, 1, 0) as holiday,

		COUNT(DISTINCT sok.client_id) as clientCnt,

    #IF(h.date, (), IF(p.afterwork, (), (_work_), 0)) as altPaymentCnt

    IF(sus.id, sus.COUNT(DISTINCT sok.client_id, sok.service_id),
			IF(susg.id, COUNT(DISTINCT sok.client_id, s.group_id),
				IF(ss.id, COUNT(DISTINCT sok.client_id, sok.service_id),
					IF(ssg.id, COUNT(DISTINCT sok.client_id, s.group_id),
						IF(su.id, COUNT(DISTINCT sok.client_id),
							IF(sb.id, COUNT(DISTINCT sok.client_id), 0)
						)
					)
				)
			)
		) as altPaymentCnt,

		COUNT(DISTINCT sok.client_id, sok.service_id) 
			* IF(sus.id AND sus.holiday_payment > 0, IF(h.date, 1, 0), 0) as sus_holidayPaymentCnt,
		COUNT(DISTINCT sok.client_id, sok.service_id) 
			* IF(sus.id AND sus.afterwork_payment > 0, IF(h.date IS NULL AND p.afterwork, 1, 0), 0) as sus_afterworkPaymentCnt,
		COUNT(DISTINCT sok.client_id, sok.service_id) 
			* IF(sus.id AND sus.work_payment > 0, IF(h.date IS NULL AND p.afterwork IS NULL, 1, 0), 0) as sus_workPaymentCnt,
		COUNT(DISTINCT sok.client_id, sok.service_id)
		  * IF(sus.id AND(
          (h.date AND sus.holiday_payment>0)
          OR (h.date IS NULL AND p.afterwork AND sus.afterwork_payment>0)
          OR (h.date IS NULL AND p.afterwork IS NULL AND sus.work_payment>0)
		    ),1, 0) as sus_paymentCnt,
		COUNT(DISTINCT sok.client_id, sok.service_id)
		  * IF(sus.id  AND sus.holiday_payment > 0, IF(h.date, sus.holiday_payment, 0), 0) as sus_holidayPaymentSum,
		COUNT(DISTINCT sok.client_id, sok.service_id)
		  * IF(sus.id  AND sus.afterwork_payment > 0, IF(h.date IS NULL AND p.afterwork, sus.afterwork_payment, 0), 0)
		  as sus_afterworkPaymentSum,
		COUNT(DISTINCT sok.client_id, sok.service_id)
		  * IF(sus.id AND sus.work_payment > 0, IF(h.date IS NULL AND p.afterwork IS NULL, sus.work_payment, 0), 0)
		  as sus_workPaymentSum,
		COUNT(DISTINCT sok.client_id, sok.service_id)
		  * IF(sus.id, IF(h.date, sus.holiday_payment, IF(p.afterwork, sus.afterwork_payment, sus.work_payment)), 0) as sus_paymentSum,


		COUNT(DISTINCT sok.client_id, s.group_id)
			* IF(susg.id AND susg.holiday_payment > 0, IF(h.date, 1, 0), 0) as susg_holidayPaymentCnt,
		COUNT(DISTINCT sok.client_id, s.group_id)
			* IF(susg.id AND susg.afterwork_payment > 0, IF(h.date IS NULL AND p.afterwork, 1, 0), 0) as susg_afterworkPaymentCnt,
		COUNT(DISTINCT sok.client_id, s.group_id)
			* IF(susg.id AND susg.work_payment > 0, IF(h.date IS NULL AND p.afterwork IS NULL, 1, 0), 0) as susg_workPaymentCnt,
		COUNT(DISTINCT sok.client_id, s.group_id)
		  * IF(susg.id AND(
          (h.date AND susg.holiday_payment>0)
          OR (h.date IS NULL AND p.afterwork AND susg.afterwork_payment>0)
          OR (h.date IS NULL AND p.afterwork IS NULL AND susg.work_payment>0)
		    ),1, 0) as susg_paymentCnt,
		COUNT(DISTINCT sok.client_id, s.group_id)
		  * IF(susg.id  AND susg.holiday_payment > 0, IF(h.date, susg.holiday_payment, 0), 0) as susg_holidayPaymentSum,
		COUNT(DISTINCT sok.client_id, s.group_id)
		  * IF(susg.id  AND susg.afterwork_payment > 0, IF(h.date IS NULL AND p.afterwork, susg.afterwork_payment, 0), 0)
		  as susg_afterworkPaymentSum,
		COUNT(DISTINCT sok.client_id, s.group_id)
		  * IF(susg.id AND susg.work_payment > 0, IF(h.date IS NULL AND p.afterwork IS NULL, susg.work_payment, 0), 0)
		  as susg_workPaymentSum,
		COUNT(DISTINCT sok.client_id, s.group_id)
		  * IF(susg.id, IF(h.date, susg.holiday_payment, IF(p.afterwork, susg.afterwork_payment, susg.work_payment)), 0) as susg_paymentSum,



		COUNT(DISTINCT sok.client_id, sok.service_id)
			* IF(ss.id AND ss.holiday_payment > 0, IF(h.date, 1, 0), 0) as ss_holidayPaymentCnt,
		COUNT(DISTINCT sok.client_id, sok.service_id)
			* IF(ss.id AND ss.afterwork_payment > 0, IF(h.date IS NULL AND p.afterwork, 1, 0), 0) as ss_afterworkPaymentCnt,
		COUNT(DISTINCT sok.client_id, sok.service_id)
			* IF(ss.id AND ss.work_payment > 0, IF(h.date IS NULL AND p.afterwork IS NULL, 1, 0), 0) as ss_workPaymentCnt,
		COUNT(DISTINCT sok.client_id, sok.service_id)
		  * IF(ss.id AND(
          (h.date AND ss.holiday_payment>0)
          OR (h.date IS NULL AND p.afterwork AND ss.afterwork_payment>0)
          OR (h.date IS NULL AND p.afterwork IS NULL AND ss.work_payment>0)
		    ),1, 0) as ss_paymentCnt,
		COUNT(DISTINCT sok.client_id, sok.service_id)
		  * IF(ss.id  AND ss.holiday_payment > 0, IF(h.date, ss.holiday_payment, 0), 0) as ss_holidayPaymentSum,
		COUNT(DISTINCT sok.client_id, sok.service_id)
		  * IF(ss.id  AND ss.afterwork_payment > 0, IF(h.date IS NULL AND p.afterwork, ss.afterwork_payment, 0), 0)
		  as ss_afterworkPaymentSum,
		COUNT(DISTINCT sok.client_id, sok.service_id)
		  * IF(ss.id AND ss.work_payment > 0, IF(h.date IS NULL AND p.afterwork IS NULL, ss.work_payment, 0), 0)
		  as ss_workPaymentSum,
		COUNT(DISTINCT sok.client_id, sok.service_id)
		  * IF(ss.id, IF(h.date, ss.holiday_payment, IF(p.afterwork, ss.afterwork_payment, ss.work_payment)), 0) as ss_paymentSum,


		COUNT(DISTINCT sok.client_id, s.group_id)
			* IF(ssg.id AND ssg.holiday_payment > 0, IF(h.date, 1, 0), 0) as ssg_holidayPaymentCnt,
		COUNT(DISTINCT sok.client_id, s.group_id)
			* IF(ssg.id AND ssg.afterwork_payment > 0, IF(h.date IS NULL AND p.afterwork, 1, 0), 0) as ssg_afterworkPaymentCnt,
		COUNT(DISTINCT sok.client_id, s.group_id)
			* IF(ssg.id AND ssg.work_payment > 0, IF(h.date IS NULL AND p.afterwork IS NULL, 1, 0), 0) as ssg_workPaymentCnt,
		COUNT(DISTINCT sok.client_id, s.group_id)
		  * IF(ssg.id AND(
          (h.date AND ssg.holiday_payment>0)
          OR (h.date IS NULL AND p.afterwork AND ssg.afterwork_payment>0)
          OR (h.date IS NULL AND p.afterwork IS NULL AND ssg.work_payment>0)
		    ),1, 0) as ssg_paymentCnt,
		COUNT(DISTINCT sok.client_id, s.group_id)
		  * IF(ssg.id  AND ssg.holiday_payment > 0, IF(h.date, ssg.holiday_payment, 0), 0) as ssg_holidayPaymentSum,
		COUNT(DISTINCT sok.client_id, s.group_id)
		  * IF(ssg.id  AND ssg.afterwork_payment > 0, IF(h.date IS NULL AND p.afterwork, ssg.afterwork_payment, 0), 0)
		  as ssg_afterworkPaymentSum,
		COUNT(DISTINCT sok.client_id, s.group_id)
		  * IF(ssg.id AND ssg.work_payment > 0, IF(h.date IS NULL AND p.afterwork IS NULL, ssg.work_payment, 0), 0)
		  as ssg_workPaymentSum,
		COUNT(DISTINCT sok.client_id, s.group_id)
		  * IF(ssg.id, IF(h.date, ssg.holiday_payment, IF(p.afterwork, ssg.afterwork_payment, ssg.work_payment)), 0) as ssg_paymentSum,



		COUNT(DISTINCT sok.client_id)
			* IF(su.id AND su.holiday_payment > 0, IF(h.date, 1, 0), 0) as su_holidayPaymentCnt,
		COUNT(DISTINCT sok.client_id)
			* IF(su.id AND su.afterwork_payment > 0, IF(h.date IS NULL AND p.afterwork, 1, 0), 0) as su_afterworkPaymentCnt,
		COUNT(DISTINCT sok.client_id)
			* IF(su.id AND su.work_payment > 0, IF(h.date IS NULL AND p.afterwork IS NULL, 1, 0), 0) as su_workPaymentCnt,
		COUNT(DISTINCT sok.client_id)
		  * IF(su.id AND(
          (h.date AND su.holiday_payment>0)
          OR (h.date IS NULL AND p.afterwork AND su.afterwork_payment>0)
          OR (h.date IS NULL AND p.afterwork IS NULL AND su.work_payment>0)
		    ),1, 0) as su_paymentCnt,
		COUNT(DISTINCT sok.client_id)
		  * IF(su.id  AND su.holiday_payment > 0, IF(h.date, su.holiday_payment, 0), 0) as su_holidayPaymentSum,
		COUNT(DISTINCT sok.client_id)
		  * IF(su.id  AND su.afterwork_payment > 0, IF(h.date IS NULL AND p.afterwork, su.afterwork_payment, 0), 0)
		  as su_afterworkPaymentSum,
		COUNT(DISTINCT sok.client_id)
		  * IF(su.id AND su.work_payment > 0, IF(h.date IS NULL AND p.afterwork IS NULL, su.work_payment, 0), 0)
		  as su_workPaymentSum,
		COUNT(DISTINCT sok.client_id)
		  * IF(su.id, IF(h.date, su.holiday_payment, IF(p.afterwork, su.afterwork_payment, su.work_payment)), 0) as su_paymentSum,



		COUNT(DISTINCT sok.client_id)
			* IF(sb.id AND sb.holiday_payment > 0, IF(h.date, 1, 0), 0) as sb_holidayPaymentCnt,
		COUNT(DISTINCT sok.client_id)
			* IF(sb.id AND sb.afterwork_payment > 0, IF(h.date IS NULL AND p.afterwork, 1, 0), 0) as sb_afterworkPaymentCnt,
		COUNT(DISTINCT sok.client_id)
			* IF(sb.id AND sb.work_payment > 0, IF(h.date IS NULL AND p.afterwork IS NULL, 1, 0), 0) as sb_workPaymentCnt,
		COUNT(DISTINCT sok.client_id)
		  * IF(sb.id AND(
          (h.date AND sb.holiday_payment>0)
          OR (h.date IS NULL AND p.afterwork AND sb.afterwork_payment>0)
          OR (h.date IS NULL AND p.afterwork IS NULL AND sb.work_payment>0)
		    ),1, 0) as sb_paymentCnt,
		COUNT(DISTINCT sok.client_id)
		  * IF(sb.id  AND sb.holiday_payment > 0, IF(h.date, sb.holiday_payment, 0), 0) as sb_holidayPaymentSum,
		COUNT(DISTINCT sok.client_id)
		  * IF(sb.id  AND sb.afterwork_payment > 0, IF(h.date IS NULL AND p.afterwork, sb.afterwork_payment, 0), 0)
		  as sb_afterworkPaymentSum,
		COUNT(DISTINCT sok.client_id)
		  * IF(sb.id AND sb.work_payment > 0, IF(h.date IS NULL AND p.afterwork IS NULL, sb.work_payment, 0), 0)
		  as sb_workPaymentSum,
		COUNT(DISTINCT sok.client_id)
		  * IF(sb.id, IF(h.date, sb.holiday_payment, IF(p.afterwork, sb.afterwork_payment, sb.work_payment)), 0) as sb_paymentSum


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

		WHERE sok.deleted=0 #AND sok.date >= "2015-10-01" AND sok.date <= "2015-10-30"

	GROUP BY sok.date, sok.user_id
) t

LEFT JOIN user u ON user_id = u.id

GROUP BY user_id
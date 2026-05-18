create database hr_analytics

use hr_analytics

/* Exploración de datos */

select 
    sum(case when MonthlyIncome is null then 1 else 0 end) as nulos_ingreso,
    sum(case when Department is null then 1 else 0 end) as nulos_depto,
    sum(case when Attrition is null then 1 else 0 end) as nulos_attrition
from hr_analytics;

-- No hay datos nulos en "MonthlyIncome", "Department" y "Attrition"

select distinct department
from hr_analytics

select department, count(*) as cantidad_empleados
from hr_analytics
group by department 

select attrition, count(*) as bajas
from hr_analytics
group by attrition 

select department, count(*) bajas_empleados, attrition
from hr_analytics
group by department, attrition
order by attrition  desc

select department, count(*) as cantidad_bajas, avg(monthlyincome) salario_promedio
from hr_analytics
where attrition = 'yes'
group by department

-- el departamento R&D tuvo 133 bajas y tenian un salario promedio de 4.108$ 
-- el departamento Sales tuvo 93 bajas y tenian un salario promedio de 5.961$ 
-- el departamento HHRR tuvo 12 bajas y tenian un salario promedio de 3.715$ 



select
	overtime,
	count(case when attrition = 'yes' then 1 end) as bajas,
	count(case when attrition = 'no' then 1 end) as quedaron,
	count(*) as total_empleados
from hr_analytics
group by overtime
order by overtime

-- de los 1062 empleados que no hacian overtime, se fueron 110 y se quedaron 952 
-- de los 418 empleados que hacian overtime, se fueron 128 y se quedaron 290 

SELECT
    OverTime,
    COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) as bajas,
    COUNT(*) as total,
    ROUND(COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*), 1) as porcentaje_rotacion
FROM hr_analytics
GROUP BY OverTime

select max(PerformanceRating), min(PerformanceRating)
from hr_analytics

select max(JobSatisfaction), min(jobsatisfaction)
from hr_analytics

select max(Worklifebalance), min(Worklifebalance)
from hr_analytics

CREATE VIEW vista_empleados AS
SELECT 
    EmpID as id_empleado,
    Age as edad,
    CASE 
        WHEN Age < 30 THEN 'Joven'
        WHEN Age BETWEEN 30 AND 44 THEN 'Medio'
        ELSE 'Senior'
    END as rango_edad,
    Department as departamento,
    JobRole as puesto,
    MonthlyIncome as salario_mensual_num,
    CASE
        WHEN MonthlyIncome < 3000 THEN 'Bajo'
        WHEN MonthlyIncome BETWEEN 3000 AND 6000 THEN 'Medio'
        ELSE 'Alto'
    END as salario_mensual,
    Attrition as rotacion,
    case
    	when attrition = 'yes' then 'Baja' else 'Activo'
    end as estado_empleado,
    OverTime,
    case
    	when overtime = 'yes' then 'Horas extras' else 'No horas extras'
    end as horas_extra,
    JobSatisfaction as satisfaccion_trabajo_num,
    case
    	when jobSatisfaction = 1 then 'Muy insatisfecho'
    	when jobSatisfaction = 2 then 'Insatisfecho'
    	when jobSatisfaction = 3 then 'Satisfecho'
    	when jobSatisfaction = 4 then 'Muy satisfecho'
    end as satisfaccion_trabajo,
    YearsAtCompany as anios_en_empresa,
    PerformanceRating as rendimiento_trabajo_num,
   	case
   		when PerformanceRating = 1 then 'Malo'
   		when PerformanceRating = 2 then 'Regular'
   		when PerformanceRating = 3 then 'Bueno'
   		when PerformanceRating = 4 then 'Excelente'
   	end as rendimiento_trabajo,
    WorkLifeBalance as balance_vida_trabajo_num,
    case
    	when Worklifebalance = 1 then 'Malo'
    	when Worklifebalance = 2 then 'Regular'
    	when Worklifebalance = 3 then 'Bueno'
    	when Worklifebalance = 4 then 'Excelente'
    end as balance_vida_trabajo,
    distancefromhome as distancia_km,
    case
    	when distancefromhome <= 5 then 'Cerca'
    	when distancefromhome between 5 and 15 then 'Media'
    	when distancefromhome > 15 then 'Lejos'
    end as distancia_desde_casa
FROM hr_analytics;

select *
from vista_empleados
limit 5


-- pregunta 1, Departamento con mayor bajas

select departamento, 
	count(case when rotacion = 'yes' then 1 end) as bajas,
	count(*) as total,
	round(count(case when rotacion = 'Yes' then 1 end) * 100.0 / count(*), 1) as porcentaje_rotacion
from vista_empleados
group by departamento
order by porcentaje_rotacion desc

-- pregunta 2, Rotacion por overtime

select horas_extra,
    count(case when rotacion = 'Yes' then 1 end) as bajas,
    count(*) as total,
    round(count(case when rotacion = 'Yes' then 1 end) * 100.0 / count(*), 1) as porcentaje_rotacion
from vista_empleados
group by horas_extra

-- pregunta 3, Salario de los que se van

select departamento,
	count(*) bajas_empleados, 
	round(avg(salario_mensual_num), 0) as salario
from vista_empleados
where rotacion = 'yes'
group by departamento
order by salario desc

-- pregunta 4, Edad de los que más se van

select rango_edad,
	count(case when rotacion = 'yes' then 1 end) as bajas,
	count(*) as total,
	round(count(case when rotacion = 'yes' then 1 end) * 100.0 / count(*), 1) as porcentaje_bajas
from vista_empleados
group by rango_edad

-- pregunta 5, Satisfaccion laboral en bajas

select satisfaccion_trabajo,
	count(case when rotacion = 'yes' then 1 end) as bajas,
	count(*) as total,
	round(count(case when rotacion = 'yes' then 1 end) * 100.0 / count(*), 1) as porcentaje_bajas
from vista_empleados
group by satisfaccion_trabajo 
order by porcentaje_bajas desc

-- pregunta 6, Perfil de empleado que más rota

select rango_edad, horas_extra, departamento,
	count(case when rotacion = 'yes' then 1 end) as bajas
from vista_empleados
where rotacion = 'yes'
group by departamento, rango_edad, horas_extra
order by bajas desc

-- pregunta 7, Ranking de puestos con más rotación dentro de cada departamento

with rotacion_puesto as (
    select departamento, puesto,
           count(case when rotacion = 'yes' then 1 end) as bajas,
           count(*) as total,
           round(count(case when rotacion = 'yes' then 1 end) * 100.0 / count(*), 1) as porcentaje
    from vista_empleados
    group by departamento, puesto
    order by porcentaje desc
)
select *,
    rank() over (partition by departamento order by porcentaje desc) as ranking
from rotacion_puesto

-- preunta 8, Empleados que ganan mas del promedio de su departamento

with cte as (
	select id_empleado, salario_mensual_num, departamento,
		round(avg(salario_mensual_num) over(partition by departamento), 0) as promedio_x_depto
	from vista_empleados
)
select *, 
	case
		when salario_mensual_num > promedio_x_depto then 'Gana más que el promedio' 
		else 'Gana menos que el promedio'
	end as salario
from cte
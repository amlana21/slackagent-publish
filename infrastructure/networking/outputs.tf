output "task_sg_id" {
    value = aws_security_group.app_ecs_task_sg.id
}

output vpc_id {
    value = aws_vpc.appvpc.id
}

output "subnet_ids"{
    value = aws_subnet.app_public.*.id
}
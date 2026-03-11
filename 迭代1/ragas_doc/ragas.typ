#import "./template.typ": *

#show: assignment_class.with(
  title: "Ragas 源码泛读文档",
  author: "华振翔 王涵 柯羽桐 蔡宇阳 张屹峰 张家浩",
  course: "软件工程与计算 III",
  professor_name: "2025年",
  semester: "秋季学期",
  due_time: datetime.today(),
  id: "",
)

#show: frame-style(styles.thmbox)

#include "1-intro.typ"

#include "2-software-architecture.typ"

#include "3-class-description.typ"

#include "4-class-diagram.typ"

#include "5-function-to-class-mapping.typ"

#include "6-reading-insights.typ"

#bibliography("ragas.bib")

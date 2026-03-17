#import "./template.typ": *

#show: assignment_class.with(
  title: "Ragas 源码泛读报告",
  author: "华振翔 王涵 柯羽桐 蔡宇阳 张屹峰 张家浩",
  course: "软件工程与计算 III",
  professor_name: "2026年",
  semester: "春季学期",
  due_time: datetime.today(),
  id: "",
)

#show: frame-style(styles.thmbox)

#outline()

#pagebreak()

#include "1-intro.typ"

#pagebreak()

#include "2-software-architecture.typ"

#pagebreak()

#include "3-class-description.typ"

#pagebreak()

#include "4-class-diagram.typ"

#pagebreak()

#include "5-function-to-class-mapping.typ"

#pagebreak()

#include "6-reading-insights.typ"

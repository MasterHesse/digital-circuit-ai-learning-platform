package dev.masterhesse.diglearn.question.domain;

/**
 * 题目所属题池。
 * 推荐系统核心约束：章节练习题（CHAPTER）和补充推荐题（SUPPLEMENT）严格隔离。
 * 当用户在 CHAPTER 题中答错后，推荐系统只从 SUPPLEMENT 池中选题，
 * 避免把同 KP 的其他章节练习题作为"推荐"反复呈现。
 */
public enum QuestionPool {

    /**
     * 章节核心练习题（每 KP 约 3 道）。
     * 出现在课内章节练习列表中，用于衡量章节掌握进度。
     */
    CHAPTER,

    /**
     * 巩固补充题（每 KP ≥ 5 道）。
     * 推荐系统的主力题源：当用户答错 CHAPTER 题时，
     * 从本池按标签权重（含跨 KP 溯源链路）推送。
     */
    SUPPLEMENT,

    /**
     * 综合模拟考试题（预留，当前 Demo 未使用）。
     */
    EXAM
}
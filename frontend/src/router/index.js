import Vue from 'vue'
import VueRouter from 'vue-router'


Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    redirect: '/index/Home'
  },
  {
    path: "/index",
    name: "index",
    component: () => import("../views/Index.vue"),
    children: [
      {
        path: "/index/Home",
        name: "/index/Home",
        component: () => import("../views/modules/Home.vue")
      },
      {
        path: "/index/Blindbox",
        name: "/index/Blindbox",
        component: () => import("../views/modules/Blindbox.vue")
      },
      {
        path: "/index/Pledge",
        name: "/index/Pledge",
        component: () => import("../views/modules/Pledge.vue")
      },
      {
        path: "/index/Upload",
        name: "/index/Upload",
        component: () => import("../views/modules/Upload.vue")
      },      
      {
        path: "/index/Temp",
        name: "/index/Temp",
        component: () => import("../views/modules/Temp.vue")
      },   
    ]
  }
]

const router = new VueRouter({
  routes
})

export default router

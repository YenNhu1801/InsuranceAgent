<template>
    <div id="app">
        <p class="lab-note">Lab 9 — Cổng đại lý bảo hiểm. Đăng nhập JWT, chọn sản phẩm, tạo báo giá rồi chuyển thành hợp đồng, sau đó tìm hợp đồng. VueJS chỉ gọi Auth và Agent Portal Gateway.</p>
        <div id="nav">
            <router-link to="/">Trang chủ</router-link>
            |
            <router-link to="/products">Sản phẩm</router-link>
            |
            <router-link to="/policies">Tìm hợp đồng</router-link>
            |
            <router-link to="/dashboard">Bảng số liệu</router-link>
            |
            <router-link to="/chat">Chat</router-link>
            |
            <router-link to="/account">Đăng nhập</router-link>
        </div>

        <hr/>

        <div id="main-container">
            <router-view/>

            <div class="btn-chat" id="livechat-compact-container" style="visibility: visible; opacity: 1;">
                <div class="btn-holder">
                    <router-link to="/chatbot" class="link">Live Chat</router-link>
                </div>
            </div>
        </div>

        <footer>
            <img src="./assets/logo_horizontal.png" alt="Logo Footer"/>
            <p><a href="https://asc.altkom.pl">Altkom Software & Consulting LAB @ 2020</a></p>
        </footer>
    </div>
</template>

<style>
    #app {
        font-family: 'Avenir', Helvetica, Arial, sans-serif;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        text-align: center;
        color: #2c3e50;
    }

    #nav {
        padding: 10px 10px 0 10px;
    }

    #nav a {
        font-weight: bold;
        color: #2c3e50;
    }

    #nav a.router-link-exact-active {
        color: #42b983;
    }

    .lab-note {
        margin: 12px auto 0;
        max-width: 920px;
        text-align: left;
        background: #eef6f1;
        border: 1px solid #1f4b3a;
        padding: 8px 12px;
    }

    #main-container {
        width: 80%;
        margin: 0 auto;
    }

    footer {
        text-align: center;
        border-top: 1px gray solid;
        margin-left: 10em;
        margin-right: 10em;
        margin-top: 30px;
    }

    footer > img {
        margin-top: 20px;
        height: 60px;
    }

    footer > hr {
        width: 90%;
    }

    footer > p > a {
        color: black;
    }

    #livechat-compact-container {
        height: 153px;
        position: fixed;
        right: 0;
        top: 30vh;
        z-index: 10000;
    }
    .btn-chat a {
        color: #fff;
        text-decoration: none;
        background: #1798F7;
        padding: 24px 20px 8px;
        display: block;
        font-weight: bold;
        font-size: 14px;
        box-shadow: 0 0 0 1px #03b2ff inset;
        border: 1px solid #144866;
        border-radius: 2px;
        -ms-transform: rotate(90deg) translate(0, -20px);
        -webkit-transform: rotate(90deg) translate(0, -20px);
        transform: rotate(90deg) translate(0, -20px);
        position: relative;
        right: -27px;
        transition: background 0.2s, right 0.2s;
    }
    .btn-chat a:hover {
        background: #47B6F5;
        right: -20px;
        transition: background 0.2s, right 0.2s;
    }
</style>

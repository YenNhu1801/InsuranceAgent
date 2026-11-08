<template>
    <div class="hello">
        <h1>{{ msg }}</h1>
        <h3>Đại lý đăng nhập bằng JWT. Cổng API chặn yêu cầu chưa xác thực. Chọn sản phẩm, tạo báo giá, chuyển thành hợp đồng, rồi tìm hợp đồng.</h3>

        <img class="arch-image" alt="architecture" src="https://raw.githubusercontent.com/asc-lab/dotnetcore-microservices-poc/master/readme-images/dotnetcore-microservices-architecture.png" />
    </div>
</template>

<script>
    export default {
        name: 'Home',
        props: {
            msg: String
        }
    }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
    h3 {
        margin: 40px 0 0;
    }

    ul {
        list-style-type: none;
        padding: 0;
    }

    li {
        display: inline-block;
        margin: 0 10px;
    }

    a {
        color: #42b983;
    }

    .arch-image {
        width: 100%;
    }
</style>

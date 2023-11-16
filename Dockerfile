FROM ubuntu:22.04

RUN \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y \
		build-essential make wget texinfo git cmake ninja-build && \
	apt-get autoremove -y && \
	apt-get clean -y && \
	rm -rf /var/lib/apt/lists/*

ARG BINUTILS=2.40
ARG GCC=12.2.0

ARG PREFIX=/usr/local/mipsel-none-elf

RUN \
	wget https://ftpmirror.gnu.org/gnu/binutils/binutils-${BINUTILS}.tar.xz && \
	wget https://ftpmirror.gnu.org/gnu/gcc/gcc-${GCC}/gcc-${GCC}.tar.xz && \
	tar xvf binutils-${BINUTILS}.tar.xz && \
	tar xvf gcc-${GCC}.tar.xz && \
	rm -f *.tar.xz

RUN \
	cd gcc-${GCC} && \
	./contrib/download_prerequisites

RUN \
	mkdir binutils-build && \
	cd binutils-build && \
	../binutils-${BINUTILS}/configure \
		--prefix=${PREFIX} \
		--target=mipsel-none-elf \
		--disable-docs \
		--disable-nls \
		--disable-werror \
		--with-float=soft && \
	make -j`nproc` && \
	make install-strip

RUN \
	mkdir gcc-build && \
	cd gcc-build && \
	../gcc-${GCC}/configure \
		--prefix=${PREFIX} \
		--target=mipsel-none-elf \
		--disable-docs \
		--disable-nls \
		--disable-werror \
		--disable-libada \
		--disable-libssp \
		--disable-libquadmath \
		--disable-threads \
		--disable-libgomp \
		--disable-libstdcxx-pch \
		--disable-hosted-libstdcxx \
		--enable-languages=c,c++ \
		--without-isl \
		--without-headers \
		--with-float=soft \
		--with-gnu-as \
		--with-gnu-ld && \
	make -j`nproc` && \
	make install-strip

ENV PATH=${PATH}:${PREFIX}/bin

ARG PSN00BSDK=v0.24

RUN \
	git clone https://github.com/Lameguy64/PSn00bSDK.git && \
	cd PSn00bSDK && \
	git checkout ${PSN00BSDK} && \
	git submodule update --init --recursive && \
	cmake --preset default . && \
	cmake --build ./build && \
	cmake --install ./build

ENV PSN00BSDK_LIBS=/usr/local/lib/libpsn00b

ARG ARMIPS=a8d71f0f279eb0d30ecf6af51473b66ae0cf8e8d

RUN \
	git clone https://github.com/Kingcom/armips.git && \
	cd armips && \
	git checkout ${ARMIPS} && \
	git submodule update --init --recursive && \
	mkdir build && \
	cd build && \
	cmake -DCMAKE_BUILD_TYPE=Release .. && \
	cmake --build . && \
	mv armips /usr/local/bin/

RUN \
	rm -rf /PSn00bSDK && \
	rm -rf /binutils-${BINUTILS} && \
	rm -rf /binutils-build && \
	rm -rf /gcc-${GCC} && \
	rm -rf /gcc-build && \
	rm -rf /armips


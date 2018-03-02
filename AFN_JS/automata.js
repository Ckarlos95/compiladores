// Generated by CoffeeScript 2.2.2
var AF, AFD, AFN, Estado, Transicion,
  splice = [].splice,
  indexOf = [].indexOf;

Transicion = class Transicion {
  constructor(...simbolos) {
    var estado1, ref;
    ref = simbolos, [...simbolos] = ref, [estado1] = splice.call(simbolos, -1);
    this.estado = estado1;
    if (simbolos.length === 1) {
      // Una transicion con un solo caracter
      this.minSimbolo = this.maxSimbolo = simbolos[0].charCodeAt();
    } else {
      // Transicion con un rango de caracteres
      [this.minSimbolo, this.maxSimbolo] = [...simbolos].map(function(char) {
        return char.charCodeAt();
      });
    }
  }

};

Estado = (function() {
  class Estado {
    constructor() {
      this.aceptacion = false;
      this.transiciones = [];
      Estado.idEstado += 1;
      this.idEdo = Estado.idEstado;
    }

    agregaTransicion(...simbolos) {
      var estado, ref;
      ref = simbolos, [...simbolos] = ref, [estado] = splice.call(simbolos, -1);
      return this.transiciones.push(new Transicion(...simbolos, estado));
    }

    estadosCon(simbolo) {
      var j, len, ref, ref1, results, t;
      ref = this.transiciones;
      results = [];
      for (j = 0, len = ref.length; j < len; j += 1) {
        t = ref[j];
        if ((t.minSimbolo <= (ref1 = simbolo.charCodeAt()) && ref1 <= t.maxSimbolo)) {
          results.push(t.estado);
        }
      }
      return results;
    }

  };

  Estado.idEstado = 0;

  return Estado;

}).call(this);

//import Estado from './Estado'
Array.prototype.unique = function() {
  var j, key, output, ref, results, value;
  // Retorna arreglo con valores unicos
  // No util para array de objetos
  output = {};
  for (key = j = 0, ref = this.length; 1 !== 0 && (1 > 0 ? j < ref : j > ref); key = j += 1) {
    output[this[key]] = this[key];
  }
  results = [];
  for (key in output) {
    value = output[key];
    results.push(value);
  }
  return results;
};

Array.prototype.compare = function(array) {
  return this.length === array.length && this.every(function(elem, i) {
    return elem === array[i];
  });
};

AF = (function() {
  class AF {
    constructor(...simbolos) {
      var edoFinal, ref, ref1;
      if (simbolos.length === 0) {
        // AF vacio
        return this.vacio();
      }
      if (simbolos.length === 1) {
        // AF con transicion para un solo simbolo
        this.alfabeto = simbolos[0];
      } else {
        // AF con transicion para un rango de simbolos
        this.alfabeto = (function() {
          var results = [];
          for (var j = ref = simbolos[0].charCodeAt(), ref1 = simbolos[1].charCodeAt(); ref <= ref1 ? j <= ref1 : j >= ref1; ref <= ref1 ? j++ : j--){ results.push(j); }
          return results;
        }).apply(this).map(function(sim) {
          return String.fromCharCode(sim);
        }).join('');
      }
      this.edoInicial = new Estado;
      edoFinal = new Estado;
      edoFinal.aceptacion = true;
      this.edoInicial.agregaTransicion(...simbolos, edoFinal);
      this.estados = [this.edoInicial, edoFinal];
      this.edosAceptacion = [edoFinal];
    }

    setToken(token) {
      return this.Token = token;
    }

    getToken() {
      return this.Token;
    }

    vacio() {
      this.alfabeto = '';
      this.estados = [];
      this.edosAceptacion = [];
      this.edoInicial = null;
      return this;
    }

    agregaEstado(estado) {
      if (indexOf.call(this.estados, estado) < 0) {
        return this.estados.push(estado);
      }
    }

    uneEstados(otrosEstados) {
      var e, j, len;
      for (j = 0, len = otrosEstados.length; j < len; j += 1) {
        e = otrosEstados[j];
        this.agregaEstado(e);
      }
      return this.estados;
    }

    uneAlfabetos(otroAlfabeto) {
      return this.alfabeto = (this.alfabeto + otroAlfabeto).split('').unique().sort().join('');
    }

  };

  AF.Token;

  return AF;

}).call(this);

AFN = (function() {
  class AFN extends AF {
    constructor(...simbolos) {
      super(...simbolos);
    }

    uneAFN(otroAFN) {
      var edoAcept, j, len, nuevoFinal, nuevoInicial, ref;
      nuevoInicial = new Estado;
      nuevoFinal = new Estado;
      nuevoInicial.agregaTransicion(this.EPS, this.edoInicial);
      nuevoInicial.agregaTransicion(this.EPS, otroAFN.edoInicial);
      ref = [...this.edosAceptacion, ...otroAFN.edosAceptacion];
      for (j = 0, len = ref.length; j < len; j += 1) {
        edoAcept = ref[j];
        edoAcept.agregaTransicion(this.EPS, nuevoFinal);
        edoAcept.aceptacion = false;
      }
      nuevoFinal.aceptacion = true;
      this.estados.push(...[nuevoInicial, nuevoFinal]);
      this.edoInicial = nuevoInicial;
      this.edosAceptacion = [nuevoFinal];
      this.uneEstados(otroAFN.estados);
      this.uneAlfabetos(otroAFN.alfabeto);
      return this;
    }

    unionAnalisisLex(...otrosAFN) {
      var afn, afns, edoFinal, j, k, len, len1, nuevoInicial, ref;
      afn = new AFN();
      nuevoInicial = new Estado;
      afn.edoInicial = nuevoInicial;
      for (j = 0, len = otrosAFN.length; j < len; j += 1) {
        afns = otrosAFN[j];
        nuevoInicial.agregaTransicion(this.EPS, afns.edoInicial);
        afn.uneAlfabetos(afns.alfabeto);
        afn.uneEstados(afns.estados);
        ref = afns.edosAceptacion;
        for (k = 0, len1 = ref.length; k < len1; k += 1) {
          edoFinal = ref[k];
          afn.edosAceptacion.push(edoFinal);
        }
      }
      afn.estados.push(nuevoInicial);
      return afn;
    }

    concatenaAFN(otroAFN) {
      var edoAcept, j, len, ref;
      ref = this.edosAceptacion;
      for (j = 0, len = ref.length; j < len; j += 1) {
        edoAcept = ref[j];
        edoAcept.transiciones = otroAFN.edoInicial.transiciones;
        edoAcept.aceptacion = false;
      }
      this.edosAceptacion = otroAFN.edosAceptacion;
      this.uneEstados(otroAFN.estados.filter(function(edo) {
        return edo !== otroAFN.edoInicial;
      }));
      this.uneAlfabetos(otroAFN.alfabeto);
      return this;
    }

    cerraduraMas() {
      var estado, j, len, nuevoFinal, nuevoInicial, ref;
      nuevoInicial = new Estado;
      nuevoFinal = new Estado;
      nuevoInicial.agregaTransicion(this.EPS, this.edoInicial); // Primer transicion Epsilon
      ref = this.edosAceptacion;
      for (j = 0, len = ref.length; j < len; j += 1) {
        estado = ref[j];
        estado.agregaTransicion(this.EPS, nuevoFinal);
        estado.agregaTransicion(this.EPS, this.edoInicial);
        estado.aceptacion = false;
      }
      nuevoFinal.aceptacion = true;
      this.edoInicial = nuevoInicial;
      this.edosAceptacion = [nuevoFinal];
      this.estados.push(...[nuevoInicial, nuevoFinal]);
      return this;
    }

    cerraduraAsterisco() {
      var edoAcept, j, len, ref;
      this.cerraduraMas();
      ref = this.edosAceptacion;
      for (j = 0, len = ref.length; j < len; j += 1) {
        edoAcept = ref[j];
        this.edoInicial.agregaTransicion(this.EPS, edoAcept);
      }
      return this;
    }

    cerraduraInterrogacion() {
      var estado, j, len, nuevoFinal, nuevoInicial, ref;
      nuevoInicial = new Estado;
      nuevoFinal = new Estado;
      nuevoInicial.agregaTransicion(this.EPS, this.edoInicial);
      nuevoInicial.agregaTransicion(this.EPS, nuevoFinal);
      ref = this.edosAceptacion;
      for (j = 0, len = ref.length; j < len; j++) {
        estado = ref[j];
        estado.agregaTransicion(this.EPS, nuevoFinal);
        estado.aceptacion = false;
      }
      nuevoFinal.aceptacion = true;
      this.edoInicial = nuevoInicial;
      this.edosAceptacion = [nuevoFinal];
      this.estados.push(...[nuevoInicial, nuevoFinal]);
      return this;
    }

    cerraduraEpsilon(...estados) {
      var edoActual, estado, j, len, resultado, stack;
      edoActual = null;
      resultado = [];
      stack = [];
      for (j = 0, len = estados.length; j < len; j += 1) {
        estado = estados[j];
        stack.push(estado);
        while (stack.length) {
          edoActual = stack.pop();
          if (indexOf.call(resultado, edoActual) < 0) {
            resultado.push(edoActual);
            stack.push(...edoActual.estadosCon(this.EPS));
          }
        }
      }
      return resultado;
    }

    mover(...estados) {
      var estado, j, len, ref, resultado, simbolo;
      ref = estados, [...estados] = ref, [simbolo] = splice.call(estados, -1);
      resultado = [];
      for (j = 0, len = estados.length; j < len; j += 1) {
        estado = estados[j];
        resultado.push(...estado.estadosCon(simbolo));
      }
      return resultado;
    }

    irA(...estados) {
      var ref, simbolo;
      ref = estados, [...estados] = ref, [simbolo] = splice.call(estados, -1);
      return this.cerraduraEpsilon(...this.mover(...estados, simbolo));
    }

    cadenaValida(cadena) {
      var conjuntoEdos, edoAcept, j, k, len, len1, ref, ref1, simbolo;
      // Se aplica cerradura Epsilon al estado inicial del automata
      // y se parte de ahi
      conjuntoEdos = this.cerraduraEpsilon(this.edoInicial);
      ref = cadena.split('');
      for (j = 0, len = ref.length; j < len; j += 1) {
        simbolo = ref[j];
        conjuntoEdos = this.irA(...conjuntoEdos, simbolo);
        if (!conjuntoEdos.length) {
          // La cadena no es valida cuando la operacion IrA en
          // algun momento retorna un conjunto vacio
          return false;
        }
      }
      ref1 = this.edosAceptacion;
      for (k = 0, len1 = ref1.length; k < len1; k += 1) {
        edoAcept = ref1[k];
        if (indexOf.call(conjuntoEdos, edoAcept) >= 0) {
          return true;
        }
      }
      return false;
    }

    toAFD() {
      var afdEdoInicial, contenedorEstados, edoALlegar, edoAcept, edoActual, edosActuales, indiceEdoALlegar, indiceEdoActual, j, k, len, len1, nuevoAFD, operIrA, ref, ref1, simboloActual;
      nuevoAFD = new AFD;
      afdEdoInicial = new Estado;
      nuevoAFD.edoInicial = afdEdoInicial;
      nuevoAFD.estados.push(nuevoAFD.edoInicial);
      contenedorEstados = [this.cerraduraEpsilon(this.edoInicial)];
      indiceEdoActual = 0;
      while (true) {
        edoActual = nuevoAFD.estados[indiceEdoActual];
        edosActuales = contenedorEstados[indiceEdoActual];
        ref = this.alfabeto;
        for (j = 0, len = ref.length; j < len; j += 1) {
          simboloActual = ref[j];
          operIrA = this.irA(...edosActuales, simboloActual);
          if (!operIrA.length) {
            // Si el resultado de la operacion IrA es un conjunto vacio
            edoActual.agregaTransicion(simboloActual, AFD.prototype.EDO_ERROR);
            continue;
          }
          edoALlegar = new Estado;
          indiceEdoALlegar = contenedorEstados.findIndex(function(conjuntoEdos) {
            return conjuntoEdos.compare(operIrA);
          });
          if (indiceEdoALlegar > -1) {
            // El conjunto de estados ya fue generado
            edoALlegar = nuevoAFD.estados[indiceEdoALlegar];
            edoActual.agregaTransicion(simboloActual, edoALlegar);
            continue;
          } else {
            ref1 = this.edosAceptacion;
            for (k = 0, len1 = ref1.length; k < len1; k += 1) {
              edoAcept = ref1[k];
              if (indexOf.call(operIrA, edoAcept) >= 0) {
                edoALlegar.aceptacion = true;
                nuevoAFD.edosAceptacion.push(edoALlegar);
                break;
              }
            }
            edoActual.agregaTransicion(simboloActual, edoALlegar);
            nuevoAFD.estados.push(edoALlegar);
            contenedorEstados.push(operIrA);
          }
        }
        indiceEdoActual += 1;
        if (indiceEdoActual >= contenedorEstados.length) {
          break;
        }
      }
      nuevoAFD.alfabeto = this.alfabeto;
      nuevoAFD.estados.push(AFD.prototype.EDO_ERROR);
      return nuevoAFD;
    }

    fromRegex(regex) {
      var i, index, item, j, k, l, len, ref, ref1, result, simbolo, stack, subRegex;
      stack = [[]];
      for (j = 0, len = regex.length; j < len; j++) {
        simbolo = regex[j];
        if (simbolo === '(') {
          stack.push([]);
        } else if (simbolo === ')') {
          subRegex = stack.pop();
          stack[stack.length - 1].push(this.fromRegex(subRegex));
        } else {
          stack[stack.length - 1].push(simbolo);
        }
      }
      for (i = k = 0, ref = stack[stack.length - 1].length; (0 <= ref ? k < ref : k > ref); i = 0 <= ref ? ++k : --k) {
        item = stack[stack.length - 1][i];
        if (typeof item === 'string' && indexOf.call('|┼¤?', item) < 0) {
          stack[stack.length - 1][i] = new AFN(item);
        }
      }
      while (indexOf.call(stack[stack.length - 1], '¤') >= 0) {
        index = stack[stack.length - 1].indexOf('¤');
        stack[stack.length - 1][index - 1] = stack[stack.length - 1][index - 1].cerraduraAsterisco();
        stack[stack.length - 1].splice(index, 1);
      }
      while (indexOf.call(stack[stack.length - 1], '┼') >= 0) {
        index = stack[stack.length - 1].indexOf('┼');
        stack[stack.length - 1][index - 1] = stack[stack.length - 1][index - 1].cerraduraMas();
        stack[stack.length - 1].splice(index, 1);
      }
      while (indexOf.call(stack[stack.length - 1], '?') >= 0) {
        index = stack[stack.length - 1].indexOf('?');
        stack[stack.length - 1][index - 1] = stack[stack.length - 1][index - 1].cerraduraInterrogacion();
        stack[stack.length - 1].splice(index, 1);
      }
      i = 0;
      while (i < stack[stack.length - 1].length - 1) {
        if (!(stack[stack.length - 1][i + 1] === '|' || stack[stack.length - 1][i] === '|')) {
          stack[stack.length - 1][i] = stack[stack.length - 1][i].concatenaAFN(stack[stack.length - 1][i + 1]);
          stack[stack.length - 1].splice(i + 1, 1);
        } else {
          i++;
        }
      }
      result = stack[stack.length - 1][0];
      for (i = l = 1, ref1 = stack[stack.length - 1].length; (1 <= ref1 ? l < ref1 : l > ref1); i = 1 <= ref1 ? ++l : --l) {
        if (stack[stack.length - 1][i] !== '|') {
          result = result.uneAFN(stack[stack.length - 1][i]);
        }
      }
      return result;
    }

  };

  AFN.prototype.EPS = '\u0000';

  return AFN;

}).call(this);

AFD = (function() {
  class AFD extends AF {
    constructor(...simbolos) {
      super(...simbolos);
    }

    mover(estado, simbolo) {
      return estado.estadosCon(simbolo)[0];
    }

    cadenaValida(cadena) {
      var edoActual, j, len, simbolo, simbolos;
      simbolos = cadena.split('');
      edoActual = this.mover(this.edoInicial, simbolos.shift());
      for (j = 0, len = simbolos.length; j < len; j += 1) {
        simbolo = simbolos[j];
        if (indexOf.call(this.alfabeto, simbolo) < 0) {
          return false;
        }
        edoActual = this.mover(edoActual, simbolo);
        if (edoActual === this.EDO_ERROR) {
          return false;
        }
      }
      if (indexOf.call(this.edosAceptacion, edoActual) >= 0) {
        return true;
      }
      return false;
    }

    tabla() {
      var edollegar, estado, fila, j, k, len, len1, ref, ref1, simbolo;
      this.table = [["", ...this.alfabeto.split("")]];
      ref = this.estados;
      for (j = 0, len = ref.length; j < len; j += 1) {
        estado = ref[j];
        if (estado.aceptacion === true) {
          fila = [estado.idEdo + "*"];
        } else {
          fila = [estado.idEdo + ""];
        }
        if (estado === this.EDO_ERROR) {
          continue;
        }
        ref1 = this.alfabeto;
        for (k = 0, len1 = ref1.length; k < len1; k += 1) {
          simbolo = ref1[k];
          edollegar = this.mover(estado, simbolo);
          if (edollegar === this.EDO_ERROR) {
            fila.push(-1);
          } else {
            fila.push(edollegar.idEdo);
          }
        }
        this.table.push(fila);
      }
      return this.table;
    }

    imprimirTabla() {
      var fila, j, len, ref, results;
      console.log("\nTabla del AFD");
      ref = this.table;
      results = [];
      for (j = 0, len = ref.length; j < len; j += 1) {
        fila = ref[j];
        results.push(console.log(fila));
      }
      return results;
    }

  };

  AFD.prototype.EDO_ERROR = new Estado;

  return AFD;

}).call(this);
